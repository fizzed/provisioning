import com.fizzed.blaze.Contexts;
import com.fizzed.jne.ABI;
import com.fizzed.jne.HardwareArchitecture;
import com.fizzed.jne.OperatingSystem;
import com.fizzed.provisioning.ProvisioningHelper;
import com.fizzed.provisioning.adoptium.AdoptiumClient;
import com.fizzed.provisioning.adoptium.AdoptiumJavaRelease;
import com.fizzed.provisioning.adoptium.AdoptiumJavaReleases;
import com.fizzed.provisioning.java.ImageType;
import com.fizzed.provisioning.java.InstallerType;
import com.fizzed.provisioning.java.JavaDistro;
import com.fizzed.provisioning.java.JavaInstaller;
import com.fizzed.provisioning.liberica.LibericaClient;
import com.fizzed.provisioning.liberica.LibericaJavaRelease;
import com.fizzed.provisioning.zulu.ZuluClient;
import com.fizzed.provisioning.zulu.ZuluJavaRelease;
import org.slf4j.Logger;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.*;

import static com.fizzed.blaze.Contexts.withBaseDir;
import static com.fizzed.crux.util.Maybe.maybe;
import static java.util.Arrays.asList;


/**
 * https://whichjdk.com/
 *
 * Java Distributions:
 *
 * Azul: https://docs.azul.com/core/zulu-openjdk/install/metadata-api
 * BellSoft Liberica: https://bell-sw.com/pages/api/
 * Adoptium (Temerin): https://api.adoptium.net/q/swagger-ui/
 *
 * List of jdks:
 * https://github.com/ScoopInstaller/Java/blob/master/bucket/semeru-jdk.json
 *
 * Amazon Corretto
 * Microsoft
 * SapMachine
 * IBM Semeru
 * Alibaba Dragonwell
 * GraalVM
 * IntelliJ JBR (JetBrains Runtime)
 *
 *
 */
public class blaze {

    private final Path projectDir = withBaseDir("../").toAbsolutePath();
    private final Path dataDir = projectDir.resolve("data");
    private final Path linuxDir = projectDir.resolve("linux");
    private final Path scriptsDir = projectDir.resolve("scripts");
    private final Path resourcesDir = projectDir.resolve("resources");
    private final Logger log = Contexts.logger();
    private final Path javaInstallersFile = dataDir.resolve("java-installers.json");

    public void build_scripts() throws Exception {
        // we basically expose the methods of helpers/blaze.java into .sh and .ps1 scripts
        final List<String> methods = asList("install_maven", "install_fastfetch", "install_git_prompt");

        // we generate both .ps1 and .sh versions based on templates
        final Path shTemplateFile = resourcesDir.resolve("install-template.sh");
        final Path ps1TemplateFile = resourcesDir.resolve("install-template.ps1");

        final String shTemplateContent = Files.readString(shTemplateFile);
        final String ps1TemplateContent = Files.readString(ps1TemplateFile);

        for (String method : methods) {
            final String shContent = shTemplateContent.replace("install_template", method);
            final String ps1Content = ps1TemplateContent.replace("install_template", method);

            final String name = method.replace("_", "-");

            final Path shTargetFile = scriptsDir.resolve(name + ".sh");
            final Path ps1TargetFile = scriptsDir.resolve(name + ".ps1");

            Files.write(shTargetFile, shContent.getBytes(StandardCharsets.UTF_8), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
            log.info("Built script {}", shTargetFile);

            Files.write(ps1TargetFile, ps1Content.getBytes(StandardCharsets.UTF_8), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
            log.info("Built script {}", ps1TargetFile);
        }
    }

    public void update_java_installers() throws Exception {
        // we will collect all java installers into this array
        final List<JavaInstaller> allJavaInstallers = new ArrayList<>();

        final ZuluClient zuluClient = new ZuluClient();
        for (int javaMajorVersion : asList(25, 21, 17, 11, 8)) {
            final List<JavaInstaller> javaInstallers = new ArrayList<>();
            log.info("Fetching zulu releases for jdk version {}...", javaMajorVersion);
            final List<ZuluJavaRelease> javaReleases = zuluClient.getReleases(javaMajorVersion);
            for (ZuluJavaRelease javaRelease : javaReleases) {
                JavaInstaller javaInstaller = zuluClient.toInstaller(javaRelease);
                // only jdks
                if (javaInstaller != null && javaInstaller.getImageType() == ImageType.JDK) {
                    javaInstallers.add(javaInstaller);
                }
            }

            final List<JavaInstaller> filteredJavaInstallers = filterJavaInstallersToLatestVersion(javaInstallers);
            allJavaInstallers.addAll(filteredJavaInstallers);
        }

        final LibericaClient libericaClient = new LibericaClient();
        for (int javaMajorVersion : asList(25, 21, 17, 11, 8)) {
            final List<JavaInstaller> javaInstallers = new ArrayList<>();
            log.info("Fetching liberica releases for jdk version {}...", javaMajorVersion);
            final List<LibericaJavaRelease> javaReleases = libericaClient.getReleases(javaMajorVersion);
            for (LibericaJavaRelease javaRelease : javaReleases) {
                JavaInstaller javaInstaller = libericaClient.toInstaller(javaRelease);
                // only jdks
                if (javaInstaller != null && javaInstaller.getImageType() == ImageType.JDK) {
                    javaInstallers.add(javaInstaller);
                }
            }

            final List<JavaInstaller> filteredJavaInstallers = filterJavaInstallersToLatestVersion(javaInstallers);
            allJavaInstallers.addAll(filteredJavaInstallers);
        }

        final AdoptiumClient adoptiumClient = new AdoptiumClient();
        for (int javaMajorVersion : asList(25, 21, 17, 11)) {
            final List<JavaInstaller> javaInstallers = new ArrayList<>();
            log.info("Fetching temurin releases for jdk version {}...", javaMajorVersion);
            final List<AdoptiumJavaReleases> javaReleases1 = adoptiumClient.getReleases(javaMajorVersion);
            for (AdoptiumJavaReleases javaReleases : javaReleases1) {
                for (AdoptiumJavaRelease javaRelease : javaReleases.getBinaries()) {
                    JavaInstaller javaInstaller = adoptiumClient.toInstaller(javaRelease);
                    // only jdks
                    if (javaInstaller != null && javaInstaller.getImageType() == ImageType.JDK) {
                        javaInstallers.add(javaInstaller);
                    }
                }
            }

            final List<JavaInstaller> filteredJavaInstallers = filterJavaInstallersToLatestVersion(javaInstallers);
            allJavaInstallers.addAll(filteredJavaInstallers);
        }

        // dump out the installers
        log.trace("{}", ProvisioningHelper.getObjectMapper().writeValueAsString(allJavaInstallers));

        Files.write(this.javaInstallersFile, ProvisioningHelper.getObjectMapper().writeValueAsBytes(allJavaInstallers), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
        log.info("Wrote java-installers to file {}", this.javaInstallersFile);
    }

    private List<JavaInstaller> filterJavaInstallersToLatestVersion(List<JavaInstaller> javaInstallers) {
        List<JavaInstaller> filteredJavaInstallers = new ArrayList<>();

        // sort the list by the all the fields, with versions descending
        javaInstallers.sort(JavaInstaller.COMPARATOR);

        // find the first matching installer for the os-arch-abi-image-type combo we are looking for (this will ensure
        // we have the latest version of each
        for (OperatingSystem os : OperatingSystem.values()) {
            for (HardwareArchitecture arch : HardwareArchitecture.values()) {
                for (ABI abi : ABI.values()) {
                    for (ImageType imageType : ImageType.values()) {
                        for (InstallerType installerType : InstallerType.values()) {
                            for (JavaInstaller javaInstaller : javaInstallers) {
                                if (os == javaInstaller.getOs() && arch == javaInstaller.getArch() && abi == maybe(javaInstaller.getAbi()).orElse(ABI.DEFAULT) && imageType == javaInstaller.getImageType() && installerType == javaInstaller.getInstallerType()) {
                                    filteredJavaInstallers.add(javaInstaller);
                                    break;
                                }
                            }
                        }
                    }

                }
            }
        }

        Collections.sort(filteredJavaInstallers, JavaInstaller.COMPARATOR);

        return filteredJavaInstallers;
    }

    public void update_bootstrap_java_sh() throws Exception {
        // load the latest java installer data
        log.info("Loading java-installers from file {}", this.javaInstallersFile);
        final byte[] javaInstallersData = Files.readAllBytes(this.javaInstallersFile);
        final List<JavaInstaller> allJavaInstallers = ProvisioningHelper.getObjectMapper().readValue(javaInstallersData, new com.fasterxml.jackson.core.type.TypeReference<>() {});

        // what we are interested in loading into our linux shell script
        final List<JavaDistro> distros = asList(JavaDistro.ZULU, JavaDistro.LIBERICA, JavaDistro.TEMURIN);
        final List<Integer> javaMajorVersions = asList(25, 21, 17, 11, 8);
        final List<OperatingSystem> operatingSystems = asList(OperatingSystem.LINUX);
        // all architectures
        final List<ABI> abis = asList(ABI.DEFAULT, ABI.MUSL);

        //final List<String> distros = asList("zulu", "liberica", "nitro");
        //final List<Integer> javaVersions = asList(21, 17, 11, 8, 7);
        //final List<String> systems = asList("linux", "linux_musl");
        //final List<String> architectures = asList("x64", "x32", "arm64", "armhf", "armel", "riscv64");
        //final List<JavaInstaller> javaInstallers = new ArrayList<>();

        /*// manually include "nitro" jdk for riscv64 architectures, for ALL versions requested
        for (int version : asList(21, 19, 17, 11, 8)) {
            javaInstallers.add(new JavaInstaller()
                .setDistro("nitro")
                .setOs("linux")
                .setArch("riscv64")
                .setMajorVersion(version)
                .setMinorVersion(999999)    // something large so its the first
                .setPatchVersion(999999)    // something large so its the first
                .setType("jdk")
                .setInstallerType("tar.gz")
//                .setDownloadUrl("https://github.com/fizzed/nitro/releases/download/builds/fizzed19.36-jdk19.0.1-linux_riscv64.tar.gz"));
                .setDownloadUrl("https://github.com/fizzed/nitro/releases/download/builds/fizzed21.35-jdk21.0.1-linux_riscv64.tar.gz"));
        }

        // there is an issue w/ azul hard-float arm32 builds, we will pin ourselves to the latest version 11 that works
        javaInstallers.add(new JavaInstaller()
            .setDistro("zulu")
            .setOs("linux")
            .setArch("armhf")
            .setMajorVersion(11)
            .setMinorVersion(999999)    // something large so its the first
            .setPatchVersion(999999)    // something large so its the first
            .setType("jdk")
            .setInstallerType("tar.gz")
            .setDownloadUrl("https://cdn.azul.com/zulu-embedded/bin/zulu11.64.19-ca-jdk11.0.19-linux_aarch32hf.tar.gz"));
*/

        final String startComment = "#\n# Automatically generated list of urls (do not edit by hand)\n#\n";
        final String endComment = "#\n# End of automatically generated list of urls\n#\n";
        final StringBuilder shellSnippet = new StringBuilder();
        shellSnippet.append(startComment);

        for (JavaDistro distro : distros) {
            shellSnippet.append("if [ \"$JAVA_URL\" = \"\" ]; then\n");
            shellSnippet.append("  if [ \"$JAVA_DISTRIBUTION\" = \"\" ] || [ \"$JAVA_DISTRIBUTION\" = \""+distro.toString().toLowerCase()+"\" ]; then\n");

            for (int javaMajorVersion : javaMajorVersions) {
                shellSnippet.append("    if [ \"$JAVA_VERSION\" = \""+javaMajorVersion+"\" ]; then\n");

                for (OperatingSystem os : operatingSystems) {
                    // both DEFAULT or MUSL too
                    for (ABI abi : abis) {
                        String osAbi = os.toString().toLowerCase() + (abi == ABI.DEFAULT ? "" : "_" + abi.toString().toLowerCase());

                        shellSnippet.append("      if [ \"$JAVA_OS\" = \""+osAbi+"\" ]; then\n");

                        for (HardwareArchitecture arch : HardwareArchitecture.values()) {
                            shellSnippet.append("        if [ \"$JAVA_ARCH\" = \""+arch.toString().toLowerCase()+"\" ]; then\n");

                            // find most recent jdk, .tar.gz installer
                            JavaInstaller javaInstaller = allJavaInstallers.stream()
                                .filter(v -> distro == v.getDistro())
                                .filter(v -> javaMajorVersion == v.getVersion().getMajor())
                                .filter(v -> os == v.getOs())
                                .filter(v -> arch == v.getArch())
                                .filter(v -> abi == maybe(v.getAbi()).orElse(ABI.DEFAULT))
                                .filter(v -> ImageType.JDK == v.getImageType())
                                .filter(v -> InstallerType.TAR_GZ == v.getInstallerType())
                                .findFirst()
                                .orElse(null);

                            if (javaInstaller != null) {
//                            log.info("Found jdk for {}, {}, {} at url {}", javaVersion, system, arch, javaInstaller.getDownloadUrl());
                                shellSnippet.append("          JAVA_URL=\"" + javaInstaller.getDownloadUrl() + "\"\n");
                                shellSnippet.append("          JAVA_TARGET_DISTRO=\"" + javaInstaller.getDistro().toString().toLowerCase() + "\"\n");
                                shellSnippet.append("          JAVA_TARGET_VERSION=\"" + javaInstaller.getVersion() + "\"\n");

                            } else {
//                            log.warn("Unable to find jdk for {}, {}, {}", javaVersion, system, arch);
                                shellSnippet.append("          : # does not exist\n");
                            }

                            shellSnippet.append("        fi\n");
                        }

                        shellSnippet.append("      fi\n");
                    }
                }

                shellSnippet.append("    fi\n");
            }

            shellSnippet.append("  fi\n");
            shellSnippet.append("fi\n");
        }

        shellSnippet.append("\n");
        shellSnippet.append(endComment);

        final Path bootstrapJavaShFile = this.linuxDir.resolve("bootstrap-java.sh");
        final String bootstrapJavaShFileContent = Files.readString(bootstrapJavaShFile);
        final int startPos = bootstrapJavaShFileContent.indexOf(startComment);
        final int endPos = bootstrapJavaShFileContent.indexOf(endComment, startPos);
        if (startPos < 0 || endPos < 0) {
            throw new RuntimeException("Unable to find start/end of automatically generated list of urls in file " + bootstrapJavaShFile);
        }

        // swap in content now
        final String newBootstrapJavaShFileContent = bootstrapJavaShFileContent.substring(0, startPos) + shellSnippet + bootstrapJavaShFileContent.substring(endPos+endComment.length());

        Files.writeString(bootstrapJavaShFile, newBootstrapJavaShFileContent, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
        log.info("Wrote bootstrap-java.sh to file {}", bootstrapJavaShFile);

        //System.out.println(shellSnippet);
    }

}