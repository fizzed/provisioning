import com.fizzed.blaze.Config;
import com.fizzed.blaze.Contexts;
import com.fizzed.jne.*;
import com.fizzed.jne.internal.ShellBuilder;
import com.fizzed.jne.internal.Utils;
import org.slf4j.Logger;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.List;

import static com.fizzed.blaze.Archives.unarchive;
import static com.fizzed.blaze.Https.httpGet;
import static com.fizzed.blaze.Systems.*;
import static com.fizzed.jne.Chmod.chmod;
import static java.util.Arrays.asList;
import static java.util.Collections.emptyList;
import static java.util.Collections.singletonList;

public class blaze {
    private final Config config = Contexts.config();
    private final Logger log = Contexts.logger();
    private final Path tempDir = Paths.get(System.getProperty("java.io.tmpdir"));
    private final Path scratchDir = Contexts.withUserDir(".provisioning-ok-to-delete");
    private NativeTarget nativeTarget;
    private EnvScope scope;

    private void before(EnvScope defaultScope) throws Exception {
        this.nativeTarget = NativeTarget.detect();
        this.scope = this.resolveScope(defaultScope);

        log.info("Detected platform {} (arch {}) (abi {})", nativeTarget.getOperatingSystem(), nativeTarget.getHardwareArchitecture(), nativeTarget.getAbi());
        log.info("Using install scope {}", this.scope);

        if (scope == EnvScope.SYSTEM) {
            UserEnvironment userEnvironment = UserEnvironment.detectLogical();
            if (!userEnvironment.isElevated()) {
                throw new IllegalStateException("Cannot install to system scope without elevated permissions (maybe run it with sudo?)");
            }
            log.info("Confirmed you are running with elevated permissions :-)");
        }

        this.after(false);
        mkdir(this.scratchDir).parents().verbose().run();
    }

    private void after(boolean ignoreException) throws Exception {
        // this is just a best attempt
        try {
            rm(this.scratchDir).recursive().force().verbose().run();
        } catch (Exception e) {
            if (ignoreException) {
                log.warn("Unable to cleanly remove scratch dir: {}", this.scratchDir);
            } else {
                throw e;
            }
        }
    }

    private EnvScope resolveScope(EnvScope defaultScope) throws Exception {
        final String scopeStr = this.config.value("scope").orNull();
        if (scopeStr != null) {
            if ("user".equalsIgnoreCase(scopeStr)) {
                return EnvScope.USER;
            } else if ("system".equalsIgnoreCase(scopeStr)) {
                return EnvScope.SYSTEM;
            } else {
                throw new IllegalArgumentException("Invalid scope value: " + scopeStr);
            }
        }
        return defaultScope != null ? defaultScope : EnvScope.SYSTEM;
    }

    //
    // Apache Maven Install
    //

    final private String mavenVersion = config.value("maven.version").orElse("3.9.5");

    public void install_maven() throws Exception {
        this.before(EnvScope.SYSTEM);
        try {
            final InstallEnvironment installEnvironment = InstallEnvironment.detect("Apache Maven", "maven", this.scope);

            log.info("Installing maven v{}} with scope {}...", this.mavenVersion, this.scope);

            final NativeLanguageModel nlm = new NativeLanguageModel()
                .add("version", this.mavenVersion);

            // make sure the place we are going to is writable BEFORE we bother to download anything
            final Path targetAppDir = installEnvironment.resolveOptApplicationDir(true);

            // "https://dl.fizzed.com/maven/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
            final String url = nlm.format("https://dl.fizzed.com/maven/apache-maven-{version}-bin.tar.gz", this.nativeTarget);
            final Path archiveFile = this.scratchDir.resolve("maven.tar.gz");

            httpGet(url)
                .verbose()
                .target(archiveFile)
                .run();

            final Path unarchivedDir = this.scratchDir.resolve("maven");

            unarchive(archiveFile)
                .verbose()
                .target(unarchivedDir)
                .stripLeadingPath()
                .run();

            rm(targetAppDir)
                .verbose()
                .recursive()
                .force()
                .run();

            //log.info("confirming {} is deleted: {}", targetAppDir, !Files.exists(targetAppDir));

            // this version works across filesystems on unix
            moveDirectory(unarchivedDir, targetAppDir);

            //Files.move(unarchivedDir, targetAppDir);

//            mv(unarchivedDir)
//                .verbose()
//                .target(targetAppDir)
//                .force()
//                .run();

            // we need to fix execute permissions on everything but windows
            if (this.nativeTarget.getOperatingSystem() != OperatingSystem.WINDOWS) {
                chmod(targetAppDir.resolve("bin/mvn"), "755");
                chmod(targetAppDir.resolve("bin/mvn.cmd"), "755");
                chmod(targetAppDir.resolve("bin/mvnDebug"), "755");
                chmod(targetAppDir.resolve("bin/mvnDebug.cmd"), "755");
            }

            /*log.info("Will execute `mvn -v` to validate installation...");
            log.info("");

            exec("mvn", "-v")
                .verbose()
                .run();

            log.info("");*/

            installEnvironment.installEnv(
                // in case there is maven on the system, prepending should let us prefer this one
                singletonList(new EnvPath(targetAppDir.resolve("bin"), true)),
                singletonList(new EnvVar("M2_HOME", targetAppDir))
            );

            log.info("Successfully installed maven v{} with scope {}", this.mavenVersion, scope);
        } finally {
            this.after(true);
        }
    }

    //
    // Fastfetch Install
    //

    final private String fastfetchVersion = config.value("fastfetch.version").orElse("2.53.0");

    public void install_fastfetch() throws Exception {
        this.before(EnvScope.SYSTEM);
        try {
            final InstallEnvironment installEnvironment = InstallEnvironment.detect("FastFetch", "fastfetch", this.scope);

            log.info("Installing fastfetch v{} with scope {}...", this.fastfetchVersion, this.scope);

            // NOTE: fastfetch only publishes assets for some architectures, not all, we can make this recipe work
            // for a few more by delegating to the underlying package manager instead
            if (this.nativeTarget.getOperatingSystem() == OperatingSystem.FREEBSD && nativeTarget.getHardwareArchitecture() != HardwareArchitecture.X64) {
                exec("pkg", "install", "-y", "fastfetch")
                    .verbose()
                    .run();
                return;
            } else if (this.nativeTarget.getOperatingSystem() == OperatingSystem.OPENBSD && nativeTarget.getHardwareArchitecture() != HardwareArchitecture.X64) {
                exec("pkg_add", "fastfetch")
                    .verbose()
                    .run();
                return;
            }

            // detect current os & arch, then translate to values that nats-server project uses
            final NativeLanguageModel nlm = new NativeLanguageModel()
                .add("version", this.fastfetchVersion)
                .add(HardwareArchitecture.ARM64, "aarch64")
                .add(HardwareArchitecture.X64, "amd64")
                .add(HardwareArchitecture.ARMHF, "armv7l")
                .add(HardwareArchitecture.ARMEL, "armv6l");
            
            final Path targetLocalBinDir = installEnvironment.resolveLocalBinDir(true);
            final Path targetLocalShareDir = installEnvironment.resolveLocalShareDir(true);

            // https://github.com/fastfetch-cli/fastfetch/releases/download/2.53.0/fastfetch-linux-amd64.zip
            final String url = nlm.format("https://github.com/fastfetch-cli/fastfetch/releases/download/{version}/fastfetch-{os}-{arch}.zip", this.nativeTarget);
            final Path archiveFile = this.scratchDir.resolve("fastfetch.zip");

            httpGet(url)
                .verbose()
                .target(archiveFile)
                .run();

            final Path unarchivedDir = this.scratchDir.resolve("fastfetch");

            // NOTE: annoyingly, on windows, the archive file structure is different and its "flattened" so it all goes
            // into the same directory (including the presets), so we don't want to strip any components on that platform
            // while also adjusting the locations of everything else too
            int stripComponents = 1;
            String archiveBinDir = "usr/bin";
            String archiveShareDir = "usr/share/fastfetch";

            if (installEnvironment.getOperatingSystem() == OperatingSystem.WINDOWS) {
                stripComponents = 0;
                archiveBinDir = ".";
                archiveShareDir = ".";
            }

            unarchive(archiveFile)
                .verbose()
                .target(unarchivedDir)
                .stripComponents(stripComponents)
                .run();

            // the usr/bin/fastfetch should exist
            final String exeFileName = this.nativeTarget.resolveExecutableFileName("fastfetch");
            final Path sourceExeFile = unarchivedDir.resolve(archiveBinDir).resolve(exeFileName);

            chmod(sourceExeFile, "755");

            mv(sourceExeFile)
                .verbose()
                .target(targetLocalBinDir)
                .force()
                .run();

            // we also need the share directory for presets, etc.
            final Path sourceShareDir = unarchivedDir.resolve(archiveShareDir);
            final Path targetShareDir = targetLocalShareDir.resolve("fastfetch");

            rm(targetShareDir).recursive().force().run();

            // this version works across filesystems on unix
            moveDirectory(sourceShareDir, targetShareDir);

            /*mv(sourceShareDir)
                .verbose()
                .target(targetShareDir)
                .force()
                .run();*/

            // validate the install worked by displaying the version
            log.info("Will execute `fastfetch -v` to validate installation...");
            log.info("");

            exec(targetLocalBinDir.resolve(exeFileName), "-v")
                .run();

            log.info("");

            installEnvironment.installEnv(
                singletonList(new EnvPath(targetLocalBinDir)),
                emptyList()
            );

            log.info("Successfully installed fastfetch v{} with scope {}", this.fastfetchVersion, this.scope);
        } finally {
            this.after(true);
        }
    }

    //
    // Git Prompt into Shell Install
    //

    public void install_git_prompt() throws Exception {
        this.before(EnvScope.USER);
        try {
            final UserEnvironment userEnvironment = UserEnvironment.detectEffective();

            log.info("Installing git prompt for shell {}", userEnvironment.getShellType());

            final ShellBuilder shellBuilder;
            final Path targetFile;
            final Path sourceFile;

            if (userEnvironment.getShellType() == ShellType.BASH) {

                shellBuilder = new ShellBuilder(userEnvironment.getShellType());
                targetFile = userEnvironment.getHomeDir().resolve(".bashrc");
                sourceFile = this.getResource("git-prompt.bash");

            } else if (userEnvironment.getShellType() == ShellType.ZSH) {

                shellBuilder = new ShellBuilder(userEnvironment.getShellType());
                targetFile = userEnvironment.getHomeDir().resolve(".zshrc");
                sourceFile = this.getResource("git-prompt.zsh");

            } else if (userEnvironment.getShellType() == ShellType.TCSH) {

                shellBuilder = new ShellBuilder(userEnvironment.getShellType());
                targetFile = userEnvironment.getHomeDir().resolve(".tcshrc");
                sourceFile = this.getResource("git-prompt.tcsh");

            } else {
                throw new UnsupportedOperationException("Unsupported shell type: " + userEnvironment.getShellType());
            }

            final List<String> shellLines = new ArrayList<>();
            shellLines.addAll(shellBuilder.sectionBegin("git-prompt"));
            shellLines.add(Utils.readFileToString(sourceFile));
            shellLines.addAll(shellBuilder.sectionEnd("git-prompt"));

            Utils.writeLinesToFileWithSectionBeginAndEndLines(targetFile, shellLines, true);

            log.info("Successfully installed git prompt for shell {} to {}", userEnvironment.getShellType(), targetFile);
        } finally {
            this.after(true);
        }
    }

    //
    // Helpers
    //

    private Path getResource(String resourcePath) throws IOException {
        // are we in a local development environment?
        Path localResourcesDir = Contexts.withBaseDir("../resources").toAbsolutePath();
        if (Files.exists(localResourcesDir) && Files.isDirectory(localResourcesDir)) {
            log.info("Detected local development environment. Using local resources directory: {}", localResourcesDir);

            final Path file = localResourcesDir.resolve(resourcePath);

            if (!Files.exists(file)) {
                throw new IOException("Local resource file does not exist: " + file);
            }

            return file;
        }

        throw new IOException("Remote fetching of resources is not supported yet.");
    }

    static private void moveDirectory(Path source, Path destination) throws IOException {
        try {
            // Attempt a simple move first, which works for same-filesystem moves.
            Files.move(source, destination, StandardCopyOption.REPLACE_EXISTING);
        } catch (DirectoryNotEmptyException e) {
            // This exception should not occur for a top-level directory rename
            // if the move was successful, but is a good catch-all.
            System.err.println("Directory is not empty and cannot be moved by rename. Falling back to copy-and-delete.");
            copyThenDelete(source, destination);
        } catch (FileSystemException e) {
            // If the simple move fails, it's likely a cross-filesystem move.
            System.err.println("Cross-filesystem move detected. Falling back to copy-and-delete.");
            copyThenDelete(source, destination);
        }
    }

    private static void copyThenDelete(Path source, Path destination) throws IOException {
        Files.walkFileTree(source, new SimpleFileVisitor<Path>() {
            @Override
            public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) throws IOException {
                Path targetDir = destination.resolve(source.relativize(dir));
                Files.createDirectories(targetDir);
                return FileVisitResult.CONTINUE;
            }

            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                Files.copy(file, destination.resolve(source.relativize(file)), StandardCopyOption.REPLACE_EXISTING);
                return FileVisitResult.CONTINUE;
            }
        });

        // After copying, delete the source directory.
        Files.walkFileTree(source, new SimpleFileVisitor<Path>() {
            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                Files.delete(file);
                return FileVisitResult.CONTINUE;
            }

            @Override
            public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
                Files.delete(dir);
                return FileVisitResult.CONTINUE;
            }
        });
    }

    /*private Path resolveAppDir() throws Exception {
        Path appDir = null;
        switch (this.nativeTarget.getOperatingSystem()) {
            case MACOS:
            case LINUX:
                appDir = Paths.get("/opt");
                break;
            case FREEBSD:
            case OPENBSD:
                appDir = Paths.get("/usr/local");
                break;
            default:
                throw  new UnsupportedOperationException(this.nativeTarget.getOperatingSystem().toString() + " is not implemented yet (add to this CASE statement!)");
        }

        // amazingly, this may not exist yet
        if (!Files.exists(appDir)) {
            mkdir(appDir)
                .parents()
                .verbose()
                .run();
            // everyone needs to be able to read & execute
            this.chmodBinFile(appDir);
        }

        return appDir;
    }

    private Path resolveBinDir() throws Exception {
        Path binDir = null;
        switch (this.nativeTarget.getOperatingSystem()) {
            case MACOS:
            case LINUX:
            case FREEBSD:
            case OPENBSD:
                binDir = Paths.get("/usr/local/bin");
                break;
            default:
                throw  new UnsupportedOperationException(this.nativeTarget.getOperatingSystem().toString() + " is not implemented yet (add to this CASE statement!)");
        }

        // amazingly, this may not exist yet
        if (!Files.exists(binDir)) {
            mkdir(binDir)
                .parents()
                .verbose()
                .run();
            // everyone needs to be able to read & execute
            this.chmodBinFile(binDir);
        }

        return binDir;
    }

    private Path resolveShareDir() throws Exception {
        Path shareDir = null;
        switch (this.nativeTarget.getOperatingSystem()) {
            case MACOS:
            case LINUX:
            case FREEBSD:
            case OPENBSD:
                shareDir = Paths.get("/usr/local/share");
                break;
            default:
                throw  new UnsupportedOperationException(nativeTarget.getOperatingSystem().toString() + " is not implemented yet (add to this CASE statement!)");
        }

        // amazingly, this may not exist yet
        if (!Files.exists(shareDir)) {
            mkdir(shareDir)
                .parents()
                .verbose()
                .run();
            // everyone needs to be able to read & execute
            this.chmodBinFile(shareDir);
        }

        return shareDir;
    }

    private void installEnv(Env env) throws Exception {
        // even if running as sudo/doas, we want the user installing NOT if they are elevated
        final UserEnvironment userEnvironment = UserEnvironment.detectLogical();

        // some possible locations we will use
        final ShellType shellType = userEnvironment.getShellType();
        final Path homeDir = userEnvironment.getHomeDir();
        final Path bashEtcProfileDir = Paths.get("/etc/profile.d");
        final Path bashEtcLocalProfileDir = Paths.get("/usr/local/etc/profile.d");

        log.info("Detected homeDir: {}", homeDir);
        log.info("Detected shellType: {}", ofNullable(shellType).map(Enum::toString).orElse("UNKNOWN"));

        // linux and freebsd share the same strategy, just different locations
        if (shellType == ShellType.BASH && (
            (nativeTarget.getOperatingSystem() == OperatingSystem.LINUX && Files.exists(bashEtcProfileDir))
                || nativeTarget.getOperatingSystem() == OperatingSystem.FREEBSD)) {

            Path targetDir = bashEtcProfileDir;

            if (nativeTarget.getOperatingSystem() == OperatingSystem.FREEBSD) {
                targetDir = bashEtcLocalProfileDir;
                // on freebsd, we need to make sure the local profile dir exists
                if (!Files.exists(targetDir)) {
                    mkdir(targetDir)
                        .parents()
                        .verbose()
                        .run();
                    // everyone needs to be able to read & execute
                    this.chmodBinFile(targetDir);
                }
            }

            final Path targetFile = targetDir.resolve(env.getApplication() + ".sh");

            // build the shell file
            final StringBuilder sb = new StringBuilder();
            for (EnvVar var : env.getVars()) {
                sb.append("export ").append(var.getName()).append("=\"").append(var.getValue()).append("\"\n");
            }
            for (EnvPath path : env.getPaths()) {
                sb.append("export PATH=\"").append(path.getValue()).append(":$PATH\"\n");
            }

            // overwrite the existing file (if its present)
            Files.write(targetFile, sb.toString().getBytes(StandardCharsets.UTF_8), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);

            log.info("################################################################");
            log.info("");
            log.info("Installed {} environment for {} to {}", shellType, env.getApplication(), targetFile);
            log.info("");
            log.info("Usually a REBOOT is required for this system-wide profile to be activated...");
            log.info("");
            log.info("################################################################");

        } else if (shellType == ShellType.ZSH && nativeTarget.getOperatingSystem() == OperatingSystem.MACOS) {

            final Path pathsDir = Paths.get("/etc/paths.d");
            final Path pathFile = pathsDir.resolve(env.getApplication());

            // build the path file
            final StringBuilder sb = new StringBuilder();
            for (EnvPath path : env.getPaths()) {
                sb.append(path.getValue()).append("\n");
            }

            // overwrite the existing file (if its present)
            Files.write(pathFile, sb.toString().getBytes(StandardCharsets.UTF_8), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);

            log.info("################################################################");
            log.info("");
            log.info("Installed {} path for {} to {}", shellType, env.getApplication(), pathFile);

            // environment vars are more tricky, they need to be appended to ~/.zprofile
            final Path profileFile = homeDir.resolve(".zprofile");
            final List<String> profileFileLines = readFileLines(profileFile);

            for (EnvVar var : env.getVars()) {
                // this is the line we want to have present
                String line = "export " + var.getName() + "=\"" + var.getValue() + "\"";
                appendLineIfNotExists(profileFileLines, profileFile, line);
            }

            log.info("");
            log.info("Usually a REBOOT is required for this system-wide profile to be activated...");
            log.info("");
            log.info("################################################################");

        } else if (shellType == ShellType.CSH) {
            final Path profileFile = homeDir.resolve(".cshrc");
            final List<String> profileFileLines = readFileLines(profileFile);

            log.info("################################################################");
            log.info("");

            // append env vars first
            for (EnvVar var : env.getVars()) {
                // this is the line we want to have present
                String line = "setenv " + var.getName() + " \"" + var.getValue() + "\"";
                appendLineIfNotExists(profileFileLines, profileFile, line);
            }

            for (EnvPath path : env.getPaths()) {
                // this is the line we want to have present
                String line = "setenv PATH \"" + path.getValue() + ":${PATH}\"";
                appendLineIfNotExists(profileFileLines, profileFile, line);
            }

            log.info("");
            log.info("Usually logging OUT/IN is required for this profile to be activated...");
            log.info("");
            log.info("################################################################");

        } else if (shellType == ShellType.KSH) {
            final Path profileFile = homeDir.resolve(".profile");
            final List<String> profileFileLines = readFileLines(profileFile);

            log.info("################################################################");
            log.info("");

            // append env vars first
            for (EnvVar var : env.getVars()) {
                // this is the line we want to have present
                String line = "export " + var.getName() + "=\"" + var.getValue() + "\"";
                appendLineIfNotExists(profileFileLines, profileFile, line);
            }

            for (EnvPath path : env.getPaths()) {
                // this is the line we want to have present
                String line = "export PATH=\"" + path.getValue() + ":$PATH\"";
                appendLineIfNotExists(profileFileLines, profileFile, line);
            }

            log.info("");
            log.info("Usually logging OUT/IN is required for this profile to be activated...");
            log.info("");
            log.info("################################################################");
        }
    }*/

    /*private void checkFileExists(Path path) throws Exception {
        if (Files.notExists(path)) {
            throw new FileNotFoundException("File " + path + " does not exist!");
        }
    }

    private void checkPathWritable(Path path) throws Exception {
        if (!Files.isWritable(path)) {
            throw new IOException("Path " + path + " is not writable (perhaps you meant to run this as sudo?)");
        }
    }*/

    /*private void chmodBinFile(Path path) throws Exception {
        try {
            final Set<PosixFilePermission> v = PosixFilePermissions.fromString("rwxr-xr-x");
            Files.setPosixFilePermissions(path, v);
        } catch (UnsupportedOperationException e) {
            // fallback to hacky File method
            final File file = path.toFile();
            file.setExecutable(true);
        }
    }

    private void chmodFile(Path path, String perms) throws Exception {
        final Set<PosixFilePermission> v = PosixFilePermissions.fromString(perms);
        Files.setPosixFilePermissions(path, v);
    }*/

    private List<String> readFileLines(Path file) throws IOException {
        final List<String> profileFileLines;
        if (Files.exists(file)) {
            return Files.readAllLines(file, StandardCharsets.UTF_8);
        } else {
            return new ArrayList<>();
        }
    }

    private void appendLineIfNotExists(List<String> filesLine, Path file, String line) throws IOException {
        if (filesLine.stream().anyMatch(v -> v.equals(line))) {
            log.info("Skipping '{}' (already exists in {})", line, file);
        } else {
            log.info("Adding '{}' to {}", line, file);
            Files.write(file, ("\n"+line+"\n").getBytes(StandardCharsets.UTF_8), StandardOpenOption.CREATE, StandardOpenOption.APPEND);
        }
    }

    /*static public class EnvVar {
        final private String name;
        final private String value;

        public EnvVar(String name, String value) {
            this.name = name;
            this.value = value;
        }

        public EnvVar(String name, Path value) {
            this(name, value.toAbsolutePath().toString());
        }

        public String getName() {
            return name;
        }

        public String getValue() {
            return value;
        }
    }

    static public class EnvPath {
        final private Path value;

        public EnvPath(Path value) {
            this.value = value;
        }

        public Path getValue() {
            return value;
        }
    }

    static public class Env {
        private final String application;
        private final List<EnvVar> vars;
        private final List<EnvPath> paths;

        public Env(String application) {
            this.application = application;
            this.vars = new ArrayList<>();
            this.paths = new ArrayList<>();
        }

        public Env addVar(String name, String value) {
            this.vars.add(new EnvVar(name, value));
            return this;
        }

        public Env addVar(String name, Path value) {
            this.vars.add(new EnvVar(name, value));
            return this;
        }

        public Env addPath(Path path) {
            this.paths.add(new EnvPath(path));
            return this;
        }

        public String getApplication() {
            return application;
        }

        public List<EnvVar> getVars() {
            return vars;
        }

        public List<EnvPath> getPaths() {
            return paths;
        }

    }*/

}