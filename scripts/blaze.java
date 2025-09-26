import com.fizzed.blaze.Config;
import com.fizzed.blaze.Contexts;
import com.fizzed.jne.HardwareArchitecture;
import com.fizzed.jne.NativeLanguageModel;
import com.fizzed.jne.NativeTarget;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.PosixFilePermission;
import java.nio.file.attribute.PosixFilePermissions;
import java.util.Set;

import static com.fizzed.blaze.Archives.unarchive;
import static com.fizzed.blaze.Https.httpGet;
import static com.fizzed.blaze.Systems.*;

public class blaze {
    private final Config config = Contexts.config();
    private final Path tempDir = Paths.get(System.getProperty("java.io.tmpdir"));
    private final Path scratchDir = Contexts.withBaseDir(".provisioning");

    private void before() throws Exception {
        this.after();
        mkdir(this.scratchDir).parents().verbose().run();
    }

    private void after() throws Exception {
        rm(this.scratchDir).recursive().force().verbose().run();
    }

    private Path resolveBinDir() {
        final NativeTarget nativeTarget = NativeTarget.detect();

        switch (nativeTarget.getOperatingSystem()) {
           case LINUX:
           case FREEBSD:
           case OPENBSD:
                return Paths.get("/usr/local/bin");
            default:
                throw  new UnsupportedOperationException(nativeTarget.getOperatingSystem().toString() + " is not implemented yet (add to this CASE statement!)");
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

    final private String fastfetchVersion = config.value("fastfetch.version").orElse("2.53.0");

    public void bootstrap_fastfetch() throws Exception {
        this.before();
        try {
            // detect current os & arch, then translate to values that nats-server project uses
            final NativeTarget nativeTarget = NativeTarget.detect();
            final NativeLanguageModel nlm = new NativeLanguageModel()
                .add("version", this.fastfetchVersion)
                .add(HardwareArchitecture.ARM64, "aarch64")
                .add(HardwareArchitecture.X64, "amd64");

            // https://github.com/fastfetch-cli/fastfetch/releases/download/2.53.0/fastfetch-linux-amd64.zip
            final String url = nlm.format("https://github.com/fastfetch-cli/fastfetch/releases/download/{version}/fastfetch-{os}-{arch}.zip", nativeTarget);
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
            final String exeFileName = nativeTarget.resolveExecutableFileName("fastfetch");
            final Path exeFile = unzippedDir.resolve("usr/bin").resolve(exeFileName);
            final Path binDir = this.resolveBinDir();

            this.checkFileExists(exeFile);
            this.checkPathWritable(binDir);

            this.chmodBinFile(exeFile);

            mv(exeFile)
                .verbose()
                .target(binDir)
                .force()
                .run();
        } finally {
            //this.after();
        }
    }

}