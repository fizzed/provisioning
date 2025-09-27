import com.fizzed.blaze.Config;
import com.fizzed.blaze.Contexts;
import com.fizzed.jne.HardwareArchitecture;
import com.fizzed.jne.NativeLanguageModel;
import com.fizzed.jne.NativeTarget;
import com.fizzed.jne.OperatingSystem;
import org.slf4j.Logger;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.nio.file.attribute.PosixFilePermission;
import java.nio.file.attribute.PosixFilePermissions;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import static com.fizzed.blaze.Archives.unarchive;
import static com.fizzed.blaze.Https.httpGet;
import static com.fizzed.blaze.Systems.*;

public class blaze {
    private final Config config = Contexts.config();
    private final Logger log = Contexts.logger();
    private final Path tempDir = Paths.get(System.getProperty("java.io.tmpdir"));
    private final Path scratchDir = Contexts.withUserDir(".provisioning-ok-to-delete");
    private final NativeTarget nativeTarget;

    public blaze() {
        this.nativeTarget = NativeTarget.detect();
    }

    private void before() throws Exception {
        log.info("Detected os [{}] with arch [{}] and abi [{}]", nativeTarget.getOperatingSystem(), nativeTarget.getHardwareArchitecture(), nativeTarget.getAbi());
        this.after();
        mkdir(this.scratchDir).parents().verbose().run();
    }

    private void after() throws Exception {
        rm(this.scratchDir).recursive().force().verbose().run();
    }

    private Path resolveAppDir() throws Exception {
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
        final Shell shell = Shell.detect();
        log.info("Detected shell {}", shell);

        // some possible locations we will use
        final Path bashEtcProfileDir = Paths.get("/etc/profile.d");
        final Path bashEtcLocalProfileDir = Paths.get("/usr/local/etc/profile.d");

        // linux and freebsd share the same strategy, just different locations
        if (shell == Shell.BASH && (
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
            log.info("Installed {} environment for {} to {}", shell, env.getApplication(), targetFile);
            log.info("");
            log.info("Usually a reboot is required for this system-wide profile to be activated...");
            log.info("");
            log.info("################################################################");
        }
    }

    private void checkFileExists(Path path) throws Exception {
        if (Files.notExists(path)) {
            throw new FileNotFoundException("File " + path + " does not exist!");
        }
    }

    private void checkPathWritable(Path path) throws Exception {
        if (!Files.isWritable(path)) {
            throw new IOException("Path " + path + " is not writable (perhaps you meant to run this as sudo?)");
        }
    }

    private void chmodBinFile(Path path) throws Exception {
        final Set<PosixFilePermission> v = PosixFilePermissions.fromString("rwxr-xr-x");
        Files.setPosixFilePermissions(path, v);
    }

    private void chmodFile(Path path, String perms) throws Exception {
        final Set<PosixFilePermission> v = PosixFilePermissions.fromString(perms);
        Files.setPosixFilePermissions(path, v);
    }


    final private String mavenVersion = config.value("maven.version").orElse("3.9.5");

    public void install_maven() throws Exception {
        this.before();
        try {
            log.info("Installing maven v{}...", this.mavenVersion);

            final NativeLanguageModel nlm = new NativeLanguageModel()
                .add("version", this.mavenVersion);

            // make sure the place we are going to is writable BEFORE we bother to download anything
            final Path appDir = this.resolveAppDir();
            this.checkPathWritable(appDir);

            // "https://dl.fizzed.com/maven/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
            final String url = nlm.format("https://dl.fizzed.com/maven/apache-maven-{version}-bin.tar.gz", this.nativeTarget);
            final Path downloadFile = this.scratchDir.resolve("maven.tar.gz");

            httpGet(url)
                .verbose()
                .target(downloadFile)
                .run();

            final Path unzippedDir = this.scratchDir.resolve("maven");

            unarchive(downloadFile)
                .verbose()
                .target(unzippedDir)
                .stripLeadingPath()
                .run();

            final Path targetAppDir = appDir.resolve("maven");
            rm(targetAppDir).recursive().force().run();
            mv(unzippedDir)
                .verbose()
                .target(targetAppDir)
                .force()
                .run();

            // we need to fix execute permissions
            this.chmodBinFile(targetAppDir.resolve("bin/mvn"));
            this.chmodBinFile(targetAppDir.resolve("bin/mvn.cmd"));
            this.chmodBinFile(targetAppDir.resolve("bin/mvnDebug"));
            this.chmodBinFile(targetAppDir.resolve("bin/mvnDebug.cmd"));

            this.installEnv(new Env("maven")
                .addVar("M2_HOME", targetAppDir)
                .addPath(targetAppDir.resolve("bin"))
            );

            log.info("Successfully installed maven v{}", this.mavenVersion);
        } finally {
            this.after();
        }
    }

    final private String fastfetchVersion = config.value("fastfetch.version").orElse("2.53.0");

    public void install_fastfetch() throws Exception {
        this.before();
        try {
            log.info("Installing fastfetch v{}...", this.fastfetchVersion);

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

            // make sure the place we are going to is writable BEFORE we bother to download anything
            final Path binDir = this.resolveBinDir();
            this.checkPathWritable(binDir);
            final Path shareDir = this.resolveShareDir();
            this.checkPathWritable(shareDir);

            // https://github.com/fastfetch-cli/fastfetch/releases/download/2.53.0/fastfetch-linux-amd64.zip
            final String url = nlm.format("https://github.com/fastfetch-cli/fastfetch/releases/download/{version}/fastfetch-{os}-{arch}.zip", this.nativeTarget);
            final Path downloadFile = this.scratchDir.resolve("fastfetch.zip");

            httpGet(url)
                .verbose()
                .target(downloadFile)
                .run();

            final Path unzippedDir = this.scratchDir.resolve("fastfetch");

            unarchive(downloadFile)
                .verbose()
                .target(unzippedDir)
                .stripLeadingPath()
                .run();

            // the usr/bin/fastfetch should exist
            final String exeFileName = this.nativeTarget.resolveExecutableFileName("fastfetch");
            final Path exeFile = unzippedDir.resolve("usr/bin").resolve(exeFileName);

            this.checkFileExists(exeFile);

            this.chmodBinFile(exeFile);

            mv(exeFile)
                .verbose()
                .target(binDir)
                .force()
                .run();

            // we also need the share directory for presets, etc.
            final Path sourceShareDir = unzippedDir.resolve("usr/share/fastfetch");
            final Path targetShareDir = shareDir.resolve("fastfetch");
            rm(targetShareDir).recursive().force().run();
            mv(sourceShareDir)
                .verbose()
                .target(targetShareDir)
                .force()
                .run();

            exec(binDir.resolve(exeFileName), "-v")
                .verbose()
                .run();

            log.info("Successfully installed fastfetch v{}", this.fastfetchVersion);
        } finally {
            this.after();
        }
    }

    // Helpers

    static public enum Shell {
        BASH,
        ZSH,
        CSH,
        KSH;

        static public Shell detect() {
            final String shell = System.getenv("SHELL");
            if (shell != null) {
                if (shell.contains("bash")) {
                    return Shell.BASH;
                } else if (shell.contains("zsh")) {
                    return Shell.ZSH;
                } else if (shell.contains("csh")) {
                    return Shell.CSH;
                } else if (shell.contains("ksh")) {
                    return Shell.KSH;
                }
            }
            return null;
        }
    }

    static public class EnvVar {
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

    }

}