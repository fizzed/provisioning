import com.fizzed.blaze.Config;
import com.fizzed.blaze.Contexts;
import com.fizzed.jne.*;
import com.fizzed.jne.internal.ShellBuilder;
import com.fizzed.jne.internal.Utils;
import org.slf4j.Logger;

import java.io.IOException;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;

import static com.fizzed.blaze.Archives.unarchive;
import static com.fizzed.blaze.Contexts.fail;
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
    private final Path scratchDir = this.tempDir.resolve("work");
    private NativeTarget nativeTarget;
    private EnvScope scope;

    private void before(EnvScope defaultScope) throws Exception {
        this.nativeTarget = NativeTarget.detect();
        this.scope = this.resolveScope(defaultScope);
        final boolean skipElevatedCheck = this.config.flag("skip-elevated-check").orElse(false);

        log.info("Detected platform {} (arch {}) (abi {})", nativeTarget.getOperatingSystem(), nativeTarget.getHardwareArchitecture(), nativeTarget.getAbi());
        log.info("Using install scope {}", this.scope);

        if (!skipElevatedCheck && scope == EnvScope.SYSTEM) {
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
    // Hello World
    //

    public void dump_environment() throws Exception {
        this.before(EnvScope.USER);
        try {
            final InstallEnvironment installEnvironment = InstallEnvironment.detect("Dump Environment", "dump_env", this.scope);

            log.info("");
            log.info("Dumping install environment for scope {}...", this.scope);

            if (this.scope == EnvScope.USER) {
                log.info("");
                log.info("Please note you can pass '--scope system' to this command to dump the system environment instead of your user environment");
            }

            log.info("");

            log.info("User Environment (who initiated the script even if running as elevated e.g. via sudo) =>");
            log.info("  user: {}", installEnvironment.getUserEnvironment().getUser());
            log.info("  displayName: {}", installEnvironment.getUserEnvironment().getDisplayName());
            log.info("  elevated: {}", installEnvironment.getUserEnvironment().isElevated());
            log.info("  homeDir: {}", installEnvironment.getUserEnvironment().getHomeDir());
            log.info("  shellType: {}", installEnvironment.getUserEnvironment().getShellType());
            log.info("  shell: {}", installEnvironment.getUserEnvironment().getShell());

            log.info("");

            log.info("Install Environment (where scripts would install things to) =>");
            log.info("  operatingSystem: {}", installEnvironment.getOperatingSystem());
            log.info("  optApplicationDir: {}", installEnvironment.getOptApplicationDir());
            log.info("  localApplicationDir: {}", installEnvironment.getLocalApplicationDir());
            log.info("  localBinDir: {}", installEnvironment.getLocalBinDir());
            log.info("  localShareDir: {}", installEnvironment.getLocalShareDir());
            log.info("  systemBinDir: {}", installEnvironment.getSystemBinDir());
            log.info("  systemShareDir: {}", installEnvironment.getSystemShareDir());

            log.info("");
        } finally {
            this.after(true);
        }
    }

    //
    // Maven Install
    //

    public void install_maven() throws Exception {
        final String mavenVersion = this.config.value("version").orElse("3.9.11");

        this.before(EnvScope.SYSTEM);
        try {
            final InstallEnvironment installEnvironment = InstallEnvironment.detect("Apache Maven", "maven", this.scope);

            log.info("Installing maven v{}} with scope {}...", mavenVersion, this.scope);

            final NativeLanguageModel nlm = new NativeLanguageModel()
                .add("version", mavenVersion);

            // make sure the place we are going to is writable BEFORE we bother to download anything
            final Path targetAppDir = installEnvironment.resolveOptApplicationDir(true);

            // "https://dl.fizzed.com/maven/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
            final String url = nlm.format("https://dl.fizzed.com/maven/apache-maven-{version}.tar.gz", this.nativeTarget);
            final Path archiveFile = this.scratchDir.resolve("maven.tar.gz");

            httpGet(url)
                .verbose()
                .progress()
                .target(archiveFile, true)
                .run();

            final Path unarchivedDir = this.scratchDir.resolve("maven");

            unarchive(archiveFile)
                .verbose()
                .progress()
                .target(unarchivedDir)
                .stripLeadingPath()
                .run();

            rm(targetAppDir)
                .verbose()
                .recursive()
                .force()
                .run();

            mv(unarchivedDir)
                .verbose()
                .target(targetAppDir)
                .force()
                .run();

            // we need to fix execute permissions on everything but windows
            if (this.nativeTarget.getOperatingSystem() != OperatingSystem.WINDOWS) {
                chmod(targetAppDir.resolve("bin/mvn"), "755");
                chmod(targetAppDir.resolve("bin/mvn.cmd"), "755");
                chmod(targetAppDir.resolve("bin/mvnDebug"), "755");
                chmod(targetAppDir.resolve("bin/mvnDebug.cmd"), "755");
            }

            log.info("Will execute `mvn -v` to validate installation...");
            log.info("");

            // we need to use a "which" to include the maven/bin directory since it might not yet be in the PATH
            final Path mvnExe = which("mvn")
                .path(targetAppDir.resolve("bin"))
                .run();

            exec(mvnExe, "-v")
                .verbose()
                .workingDir(targetAppDir.resolve("bin"))
                .run();

            log.info("");

            installEnvironment.installEnv(
                // in case there is maven on the system, prepending should let us prefer this one
                singletonList(new EnvPath(targetAppDir.resolve("bin"), true)),
                singletonList(new EnvVar("M2_HOME", targetAppDir))
            );

            log.info("Successfully installed maven v{} with scope {}", mavenVersion, scope);
        } finally {
            this.after(true);
        }
    }

    //
    // Blaze Install
    //

    public void install_blaze() throws Exception {
        this.before(EnvScope.SYSTEM);
        try {
            final InstallEnvironment installEnvironment = InstallEnvironment.detect("Blaze", "blaze", this.scope);

            log.info("Installing blaze with scope {}...", this.scope);

            final Path blazeJarFile = Contexts.withBaseDir("blaze.jar").toAbsolutePath().normalize();

            // leverage blaze.jar and its built-in wrapper scripts
            final Path localBinDir = installEnvironment.resolveLocalBinDir(true);

            exec("java", "-jar", blazeJarFile, "-i", localBinDir)
                .verbose()
                .run();

            // validate the install worked by displaying the version
            log.info("Will execute `blaze -v` to validate installation...");
            log.info("");

            final Path blazeExe = which("blaze")
                .path(localBinDir)
                .run();

            // we have to execute "blaze" where we know a blaze.jar exists
            exec(blazeExe, "-v")
                .workingDir(blazeJarFile.getParent())
                .run();

            log.info("");

            installEnvironment.installEnv(
                singletonList(new EnvPath(localBinDir)),
                emptyList()
            );

            log.info("Successfully installed blaze with scope {}", this.scope);
        } finally {
            this.after(true);
        }
    }

    //
    // Fastfetch Install
    //

    public void install_fastfetch() throws Exception {
        final String fastfetchVersion = config.value("version").orElse("2.53.0");

        this.before(EnvScope.SYSTEM);
        try {
            final InstallEnvironment installEnvironment = InstallEnvironment.detect("FastFetch", "fastfetch", this.scope);

            log.info("Installing fastfetch v{} with scope {}...", fastfetchVersion, this.scope);

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
                .add("version", fastfetchVersion)
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
                .progress()
                .target(archiveFile, true)
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

            mv(sourceShareDir)
                .verbose()
                .target(targetShareDir)
                .force()
                .run();

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

            log.info("Successfully installed fastfetch v{} with scope {}", fastfetchVersion, this.scope);
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
            final String helpProfileActivateMessage;

            if (userEnvironment.getShellType() == ShellType.BASH) {

                shellBuilder = new ShellBuilder(userEnvironment.getShellType());
                targetFile = userEnvironment.getHomeDir().resolve(".bashrc");
                sourceFile = this.getResource("git-prompt.bash");
                helpProfileActivateMessage = ". ~/.bashrc";

            } else if (userEnvironment.getShellType() == ShellType.ZSH) {

                shellBuilder = new ShellBuilder(userEnvironment.getShellType());
                targetFile = userEnvironment.getHomeDir().resolve(".zshrc");
                sourceFile = this.getResource("git-prompt.zsh");
                helpProfileActivateMessage = ". ~/.zshrc";

            } else if (userEnvironment.getShellType() == ShellType.TCSH) {

                shellBuilder = new ShellBuilder(userEnvironment.getShellType());
                targetFile = userEnvironment.getHomeDir().resolve(".tcshrc");
                sourceFile = this.getResource("git-prompt.tcsh");
                helpProfileActivateMessage = "source ~/.tcshrc";

            } else if (userEnvironment.getShellType() == ShellType.KSH) {

                shellBuilder = new ShellBuilder(userEnvironment.getShellType());
                targetFile = userEnvironment.getHomeDir().resolve(".kshrc");
                sourceFile = this.getResource("git-prompt.ksh");
                helpProfileActivateMessage = ". ~/.kshrc";

            } else if (userEnvironment.getShellType() == ShellType.PS) {

                // This profile applies to the current user across all PowerShell host applications. Its path is typically
                // $HOME\Documents\PowerShell\Profile.ps1 on Windows or ~/.config/powershell/profile.ps1 on Linux/macOS.
                if (this.nativeTarget.getOperatingSystem() == OperatingSystem.WINDOWS) {
                    targetFile = userEnvironment.getHomeDir().resolve("Documents/PowerShell/Microsoft.PowerShell_profile.ps1");
                } else {
                    targetFile = userEnvironment.getHomeDir().resolve(".config/powershell/profile.ps1");
                }

                // the directory to this file may not yet exist
                final Path ps1ProfileDir = targetFile.getParent();
                if (!Files.exists(ps1ProfileDir)) {
                    Files.createDirectories(ps1ProfileDir);
                    log.info("Created powershell profile directory: {}", ps1ProfileDir);
                }

                shellBuilder = new ShellBuilder(userEnvironment.getShellType());
                sourceFile = this.getResource("git-prompt.ps1");
                helpProfileActivateMessage = ". $PROFILE";

            } else {
                throw new UnsupportedOperationException("Unsupported shell type: " + userEnvironment.getShellType());
            }

            final List<String> shellLines = new ArrayList<>();
            shellLines.addAll(shellBuilder.sectionBegin("git-prompt"));
            shellLines.add(Utils.readFileToString(sourceFile));
            shellLines.addAll(shellBuilder.sectionEnd("git-prompt"));

            Utils.writeLinesToFileWithSectionBeginAndEndLines(targetFile, shellLines, true);

            log.info("Successfully installed git prompt for shell {} to {}", userEnvironment.getShellType(), targetFile);
            log.info("");
            log.info("To activate your new profile, in your current shell you can:");
            log.info("");
            log.info("  {}", helpProfileActivateMessage);
            log.info("");
            log.info("Or you can open a new terminal or reboot your machine");
            log.info("");
        } finally {
            this.after(true);
        }
    }

    //
    // Install Java Path
    //

    public void install_java_path() throws Exception {
        final String javaMajorVersion = config.value("version").orNull();

        this.before(EnvScope.SYSTEM);
        try {
            final List<JavaHome> javaHomes = JavaHomes.detect();

            log.info("Detected the following java homes:");
            log.info("");
            if (!javaHomes.isEmpty()) {
                for (JavaHome javaHome : javaHomes) {
                    log.info("  {}", javaHome);
                }
            } else {
                fail("No java homes were detected on this system");
            }
            log.info("");

            // try to parse the version into something we want
            final Integer preferredJavaMajorVersion;

            if (javaMajorVersion != null) {
                preferredJavaMajorVersion = Integer.parseInt(javaMajorVersion);
            } else {
                // if no preferred version, find the greatest major version
                final JavaVersion latestJavaVersion = javaHomes.stream()
                    .map(JavaHome::getVersion)
                    .max(JavaVersion::compareTo)
                    .orElse(null);

                log.info("Latest java version: {}", latestJavaVersion);

                preferredJavaMajorVersion = latestJavaVersion.getMajor();
            }

            log.info("Preferred major java version: {}", preferredJavaMajorVersion);

            // find the latest java for our preferred major version
            final JavaHome preferredJavaHome = javaHomes.stream()
                .filter(v -> preferredJavaMajorVersion.equals(v.getVersion().getMajor()))
                .max((a, b) -> a.getVersion().compareTo(b.getVersion()))
                .orElse(null);

            if (preferredJavaHome == null) {
                fail("Unable to find a java home for major version " + preferredJavaMajorVersion);
            }

            log.info("Preferred java home: {}", preferredJavaHome);

            final InstallEnvironment installEnvironment = InstallEnvironment.detect("Java", "java", this.scope);

            final Path defaultJdkLink;
            final Path majorVersionJdkLink;
            final boolean mkdirs;

            if (this.scope == EnvScope.SYSTEM) {
                if (installEnvironment.getOperatingSystem() == OperatingSystem.WINDOWS) {
                    // most JDKs will install to C:\Program Files\Zulu\jdk-21 or something to that effect
                    defaultJdkLink = installEnvironment.getApplicationDir().resolve("jdk-current");
                    majorVersionJdkLink = installEnvironment.getApplicationDir().resolve("jdk-" + preferredJavaHome.getVersion().getMajor());
                    mkdirs = true;
                } else if (installEnvironment.getOperatingSystem() == OperatingSystem.MACOS) {
                    // /Library/Java/JavaVirtualMachines/liberica-jdk-17.jdk/Contents/Home
                    defaultJdkLink = Paths.get("/Library/Java/JavaVirtualMachines").resolve("jdk-current");
                    majorVersionJdkLink = Paths.get("/Library/Java/JavaVirtualMachines").resolve("jdk-" + preferredJavaHome.getVersion().getMajor());
                    mkdirs = true;
                } else {
                    // we will take the preferred java home, get the parent of it, and create our links there
                    // e.g. /usr/lib/jvm/java-17-openjdk-amd64
                    defaultJdkLink = preferredJavaHome.getDirectory().getParent().resolve("jdk-current");
                    majorVersionJdkLink = preferredJavaHome.getDirectory().getParent().resolve("jdk-" + preferredJavaHome.getVersion().getMajor());
                    mkdirs = false;
                }
            } else {
                defaultJdkLink = installEnvironment.getOptApplicationDir().resolve("jdk-current");
                majorVersionJdkLink = installEnvironment.getOptApplicationDir().resolve("jdk-" + preferredJavaHome.getVersion().getMajor());
                mkdirs = true;
            }

            log.info("Creating symlinks for current & major java homes...");
            log.info("");

            for (Path link : asList(defaultJdkLink, majorVersionJdkLink) ) {
                if (Files.exists(link)) {
                    if (!link.toString().endsWith("-current")) {
                        // we will just skip making this a symlink
                        continue;
                    }
                    if (!Files.isSymbolicLink(link)) {
                        fail("The symlink " + link + " already exists and is not a symbolic link. Please remove it and try again.");
                    } else {
                        Files.delete(link);
                    }
                }
                if (mkdirs && !Files.exists(link.getParent())) {
                    Files.createDirectories(link.getParent());
                }
                Files.createSymbolicLink(link, preferredJavaHome.getDirectory());
                log.info("  {} -> {}", link, preferredJavaHome.getDirectory());
            }

            log.info("");

            // we are now ready to install these as our new java environment
            installEnvironment.installEnv(
                asList(new EnvPath(defaultJdkLink.resolve("bin"), true)),
                asList(new EnvVar("JAVA_HOME", defaultJdkLink))
            );
        } finally {
            this.after(true);
        }
    }

    //
    // Helpers
    //

    private Path getResource(String resourcePath) throws IOException {
        // are we in a local development environment?   
        Path localResourcesDir = Contexts.withBaseDir("resources").toAbsolutePath();
        if (Files.exists(localResourcesDir) && Files.isDirectory(localResourcesDir)) {
            log.info("Detected local development environment. Using local resources directory: {}", localResourcesDir);

            final Path file = localResourcesDir.resolve(resourcePath);

            if (!Files.exists(file)) {
                throw new IOException("Local resource file does not exist: " + file);
            }

            return file;
        } else {
            // we will need to download this from the remote repository
            final String url = "https://cdn.fizzed.com/fzpkg/resources/" + resourcePath;
            final String fileName = url.substring(url.lastIndexOf('/') + 1);
            final Path downloadFile = this.scratchDir.resolve(fileName);

            httpGet(url)
                .verbose()
                .progress()
                .target(downloadFile, true)
                .run();

            return downloadFile;
        }
    }

}