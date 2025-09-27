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

    private void installEnvVar(String appName, String name, Path value, boolean truncate) throws Exception {
        this.installEnvVar(appName, name, value.toAbsolutePath().toString(), truncate);
    }

    private void installEnvVar(String appName, String name, String value, boolean truncate) throws Exception {
        // does the /etc/profile.d directory exist?
        final Path etcProfileDir = Paths.get("/etc/profile.d");
        if (Files.exists(etcProfileDir)) {
            final Path shellFile =  etcProfileDir.resolve(appName + ".sh");

            // flags we'll use to write the lines with
            OpenOption[] openOptions = new OpenOption[]{ StandardOpenOption.APPEND };
            if (truncate) {
                openOptions = new OpenOption[]{ StandardOpenOption.TRUNCATE_EXISTING, StandardOpenOption.CREATE };
            }

            String lines = "export " + name + "=\"" + value + "\"\n";
            Files.write(shellFile, lines.getBytes(StandardCharsets.UTF_8), openOptions);
        }
    }

    private void installPath(String appName, Path value, boolean truncate) throws Exception {
        // does the /etc/profile.d directory exist?
        final Path etcProfileDir = Paths.get("/etc/profile.d");
        if (Files.exists(etcProfileDir)) {
            final Path shellFile =  etcProfileDir.resolve(appName + ".sh");

            // flags we'll use to write the lines with
            OpenOption[] openOptions = new OpenOption[]{ StandardOpenOption.APPEND };
            if (truncate) {
                openOptions = new OpenOption[]{ StandardOpenOption.TRUNCATE_EXISTING, StandardOpenOption.CREATE };
            }

            String lines = "export PATH=\"" + value + ":$PATH\"\n";
            Files.write(shellFile, lines.getBytes(StandardCharsets.UTF_8), openOptions);
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

            this.installEnvVar("maven", "M2_HOME", targetAppDir, true);
            this.installPath("maven", targetAppDir.resolve("bin"), false);

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

}