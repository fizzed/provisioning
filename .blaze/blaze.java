import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
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
import com.fizzed.provisioning.java.JavaInstaller;
import com.fizzed.provisioning.liberica.LibericaClient;
import com.fizzed.provisioning.liberica.LibericaJavaRelease;
import com.fizzed.jne.JavaVersion;
import com.fizzed.provisioning.zulu.ZuluClient;
import com.fizzed.provisioning.zulu.ZuluJavaRelease;
import org.slf4j.Logger;

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
    private final Logger log = Contexts.logger();
    private final Path javaInstallersFile = dataDir.resolve("java-installers.json");
    private final ObjectMapper objectMapper;

    public blaze() {
        this.objectMapper = new ObjectMapper();
        this.objectMapper .enable(SerializationFeature.INDENT_OUTPUT);
    }



    public void update_java_installers() throws Exception {
        // we will collect all java installers into this array
        final List<JavaInstaller> allJavaInstallers = new ArrayList<>();

        final ZuluClient zuluClient = new ZuluClient();
        for (int javaMajorVersion : asList(25, 21, 17, 11, 8)) {
            final List<JavaInstaller> javaInstallers = new ArrayList<>();
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
        for (int javaMajorVersion : asList(21, 17, 11)) {
            final List<JavaInstaller> javaInstallers = new ArrayList<>();
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
        log.info("{}", ProvisioningHelper.getObjectMapper().writeValueAsString(allJavaInstallers));

        Files.write(javaInstallersFile, ProvisioningHelper.getObjectMapper().writeValueAsBytes(allJavaInstallers), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
        log.info("Wrote java-installers to file {}", javaInstallersFile);
    }

    private List<JavaInstaller> filterJavaInstallersToLatestVersion(List<JavaInstaller> javaInstallers) {
        List<JavaInstaller> filteredJavaInstallers = new ArrayList<>();

        // sort the list by the all the fields, with versions descending
        javaInstallers.sort(JavaInstaller.COMPARATOR);

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








    public void generate_bootstrap_java_sh() throws Exception {
        final List<String> distros = asList("zulu", "liberica", "nitro");
        final List<Integer> javaVersions = asList(21, 17, 11, 8, 7);
        final List<String> systems = asList("linux", "linux_musl");
        final List<String> architectures = asList("x64", "x32", "arm64", "armhf", "armel", "riscv64");
        final List<JavaInstaller> javaInstallers = new ArrayList<>();

        // fetch all azul meta data, for many version
/*
        final List<Integer> azulJavaVersions = javaVersions;
        for (Integer v : azulJavaVersions) {
            javaInstallers.addAll(this.fetch_azul_java_installers(v));
        }

        for (Integer v : javaVersions) {
            javaInstallers.addAll(this.fetch_liberica_java_installers(v));
        }
*/

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

/*        final StringBuilder shellSnippet = new StringBuilder();
        shellSnippet.append("\n");
        shellSnippet.append("#\n");
        shellSnippet.append("# Automatically generated list of urls (do not edit by hand)\n");
        shellSnippet.append("#\n");

        for (String distro : distros) {
            shellSnippet.append("if [ \"$JAVA_URL\" = \"\" ]; then\n");
            shellSnippet.append("  if [ \"$JAVA_DISTRIBUTION\" = \"\" ] || [ \"$JAVA_DISTRIBUTION\" = \""+distro+"\" ]; then\n");

            for (int javaVersion : javaVersions) {
                shellSnippet.append("    if [ \"$JAVA_VERSION\" = \""+javaVersion+"\" ]; then\n");

                for (String system : systems) {
                    shellSnippet.append("      if [ \"$JAVA_OS\" = \""+system+"\" ]; then\n");

                    for (String arch : architectures) {
                        shellSnippet.append("        if [ \"$JAVA_ARCH\" = \""+arch+"\" ]; then\n");

                        // find most recent jdk, .tar.gz installer
                        JavaInstaller javaInstaller = javaInstallers.stream()
                            .filter(v -> distro.equalsIgnoreCase(v.getDistro()))
                            .filter(v -> javaVersion == v.getMajorVersion())
                            .filter(v -> system.equalsIgnoreCase(v.getOs()))
                            .filter(v -> arch.equalsIgnoreCase(v.getArch()))
                            .filter(v -> "jdk".equalsIgnoreCase(v.getType()))
                            .filter(v -> "tar.gz".equalsIgnoreCase(v.getInstallerType()))
                            .max(JavaInstaller.VERSION_COMPARATOR)
                            .orElse(null);

                        if (javaInstaller != null) {
//                            log.info("Found jdk for {}, {}, {} at url {}", javaVersion, system, arch, javaInstaller.getDownloadUrl());
                            shellSnippet.append("          JAVA_URL=\"" + javaInstaller.getDownloadUrl() + "\"\n");

                        } else {
//                            log.warn("Unable to find jdk for {}, {}, {}", javaVersion, system, arch);
                            shellSnippet.append("          : # does not exist\n");
                        }

                        shellSnippet.append("        fi\n");
                    }

                    shellSnippet.append("      fi\n");
                }

                shellSnippet.append("    fi\n");
            }

            shellSnippet.append("  fi\n");
            shellSnippet.append("fi\n");
        }

        shellSnippet.append("\n");
        shellSnippet.append("#\n");
        shellSnippet.append("# End of automatically generated list of urls\n");
        shellSnippet.append("#\n");
        shellSnippet.append("\n");

        System.out.println(shellSnippet);*/
    }

}