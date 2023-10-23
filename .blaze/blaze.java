import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fizzed.blaze.Contexts;
import org.slf4j.Logger;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import static com.fizzed.blaze.Contexts.withBaseDir;
import static java.util.Arrays.asList;

public class blaze {

    private final Path projectDir = withBaseDir("../").toAbsolutePath();
    private final Path linuxDir = projectDir.resolve("linux");
    private final Logger log = Contexts.logger();
    private final ObjectMapper objectMapper;

    public blaze() {
        this.objectMapper = new ObjectMapper();
        this.objectMapper .enable(SerializationFeature.INDENT_OUTPUT);
    }

    public void generate_bootstrap_java_sh() throws Exception {
        final List<String> distros = asList("zulu", "nitro");
        final List<Integer> javaVersions = asList(21, 17, 11, 8, 7);
        final List<String> systems = asList("linux", "linux_musl");
        final List<String> architectures = asList("x64", "x32", "arm64", "armhf", "armel", "riscv64");
        final List<JavaInstaller> javaInstallers = new ArrayList<>();

        // fetch all azul meta data, for many version
        final List<Integer> azulJavaVersions = javaVersions;
        for (Integer v : azulJavaVersions) {
            javaInstallers.addAll(this.fetch_azul_java_installers(v));
        }

        // manually include "nitro" jdk for riscv64 architectures, for ALL versions requested
        for (int version : asList(21, 19, 17, 11, 8)) {
            JavaInstaller nitroRiscv64Jdk19 = new JavaInstaller()
                .setDistro("nitro")
                .setOs("linux")
                .setArch("riscv64")
                .setMajorVersion(version)
                .setType("jdk")
                .setInstallerType("tar.gz")
                .setDownloadUrl("https://github.com/fizzed/nitro/releases/download/builds/fizzed19.36-jdk19.0.1-linux_riscv64.tar.gz");
            javaInstallers.add(nitroRiscv64Jdk19);
        }

        final StringBuilder shellSnippet = new StringBuilder();
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

//                            String libc = "glibc";
//                            if (system.equalsIgnoreCase("linux_musl")) {
//                                libc = "musl";
//                            }
//                            shellSnippet.append("    elif [ \"$JAVA_VERSION\" = \"" + javaVersion + "\" ] && [ \"$JAVA_ARCH\" = \"" + arch + "\" ] && [ \"$CLIB\" = \"" + libc + "\" ]; then\n");
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

        System.out.println(shellSnippet);
    }

    private List<JavaInstaller> fetch_azul_java_installers(int javaMajorVersion) throws Exception {
        // download metadata from azul
        // https://api.azul.com/metadata/v1/zulu/packages
        final HttpClient client = HttpClient.newHttpClient();
        final HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create("https://api.azul.com/metadata/v1/zulu/packages?java_version="+javaMajorVersion))
            .build();
        final String responseJson = client.send(request, HttpResponse.BodyHandlers.ofString())
            .body();

        final List<JavaInstaller> javaInstallers = new ArrayList<>();
        final JsonNode doc = objectMapper.readTree(responseJson);
        doc.forEach(n -> {
            try {
                JavaInstaller javaInstaller = this.parseAzulMeta(n);
                if (javaInstaller != null) {
                    javaInstallers.add(javaInstaller);
                }
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        });

        for (JavaInstaller javaInstaller : javaInstallers) {
            // dump out valid jdk installers
//            if (javaInstaller.getType().equals("jdk") && javaInstaller.getLatest()) {
                log.info("{}: version={}, installer={}, os={}, arch={}, url={}", javaInstaller.getType(),
                    javaInstaller.getVersion(), javaInstaller.getInstallerType(),
                    javaInstaller.getOs(), javaInstaller.getArch(), javaInstaller.getDownloadUrl());
//            }
        }

        return javaInstallers;
    }

    private JavaInstaller parseAzulMeta(JsonNode node) throws Exception {
        log.info("{}", objectMapper.writeValueAsString(node));

        final JavaInstaller javaInstaller = new JavaInstaller();

        javaInstaller.setDistro("zulu");
        javaInstaller.setDownloadUrl(node.get("download_url").asText());
        // zulu17.34.19-ca-jdk17.0.3-macosx_aarch64.tar.gz
        javaInstaller.setName(node.get("name").asText());
//        javaInstaller.setLatest(node.get("latest").asBoolean());

        // "java_version" : [ 17, 0, 3 ],
        JsonNode javaVersionNode = node.get("java_version");
        javaInstaller.setMajorVersion(javaVersionNode.get(0).asInt());
        javaInstaller.setMinorVersion(javaVersionNode.get(1).asInt());
        javaInstaller.setPatchVersion(javaVersionNode.get(2).asInt());
        javaInstaller.setVersion(javaInstaller.getMajorVersion()+"."+javaInstaller.getMinorVersion()+"."+javaInstaller.getPatchVersion());

        final String name = javaInstaller.getName();

        // type: jdk or jre?
        if (name.contains("-ca-jdk") || name.contains("-ca-hl-jdk")) {
            javaInstaller.setType("jdk");
        } else if (name.contains("-ca-jre") || name.contains("-ca-hl-jre")) {
            javaInstaller.setType("jre");
        } else if (name.contains("-ca-fx-jdk")) {
            javaInstaller.setType("fx-jdk");
        } else if (name.contains("-ca-fx-jre")) {
            javaInstaller.setType("fx-jre");
        } else if (name.contains("-ca-crac-jdk")) {
            javaInstaller.setType("crac-jdk");
        } else if (name.contains("-ca-crac-jre")) {
            javaInstaller.setType("crac-jre");
        } else if (!name.contains("jdk") || !name.contains("jre")) {
            // skip this, very odd distribution
            return null;
        } else {
            throw new IllegalArgumentException("Unable to detect java type (e.g. jdk or jre) from " + name);
        }

        // installer type: .tar.gz etc?
        if (name.endsWith(".tar.gz")) {
            javaInstaller.setInstallerType("tar.gz");
        } else if (name.endsWith(".msi")) {
            javaInstaller.setInstallerType("msi");
        } else if (name.endsWith(".zip")) {
            javaInstaller.setInstallerType("zip");
        } else if (name.endsWith(".dmg")) {
            javaInstaller.setInstallerType("dmg");
        } else if (name.endsWith(".deb")) {
            javaInstaller.setInstallerType("deb");
        } else if (name.endsWith(".rpm")) {
            javaInstaller.setInstallerType("rpm");
        } else {
            throw new IllegalArgumentException("Unable to detect installer type (e.g. .tar.gz or .msi) from " + name);
        }

        // os: linux, windows, linux_musl, etc?
        if (name.contains("-linux_musl")) {
            javaInstaller.setOs("linux_musl");
        } else if (name.contains("-linux")) {
            javaInstaller.setOs("linux");
        } else if (name.contains("-macosx")) {
            javaInstaller.setOs("macos");
        } else if (name.contains("-win")) {
            javaInstaller.setOs("windows");
        } else if (name.contains("-solaris")) {
            javaInstaller.setOs("solaris");
        } else {
            throw new IllegalArgumentException("Unable to detect os (e.g. linux) from " + name);
        }

        // arch: aarch64, etc.?
        if (name.contains("aarch64.") || name.contains("arm64.")) {
            javaInstaller.setArch("arm64");
        } else if (name.contains("x86_64.") || name.contains("x64.") || name.contains("amd64.") || name.contains("x86lx64.")) {
            javaInstaller.setArch("x64");
        } else if (name.contains("i686.") || name.contains("i386.")) {
            javaInstaller.setArch("x32");
        } else if (name.contains("aarch32hf.")) {
            javaInstaller.setArch("armhf");
        } else if (name.contains("aarch32sf.")) {
            javaInstaller.setArch("armel");
        } else if (name.contains("sparcv9.")) {
            javaInstaller.setArch("sparc");
        } else if (name.contains("ppc64.")) {
            javaInstaller.setArch("ppc64");
        } else {
            throw new IllegalArgumentException("Unable to detect arch (e.g. x86_64) from " + name);
        }

        return javaInstaller;
    }

    static public class JavaInstaller {

        static public final Comparator<JavaInstaller> VERSION_COMPARATOR = (o1, o2) -> {
            int c = o1.majorVersion.compareTo(o2.majorVersion);
            if (c == 0) {
                c = o1.minorVersion.compareTo(o2.minorVersion);
                if (c == 0) {
                    c = o1.patchVersion.compareTo(o2.patchVersion);
                }
            }
            return c;
        };

        private String distro;
        private String downloadUrl;
        private String name;
        private Integer majorVersion;
        private Integer minorVersion;
        private Integer patchVersion;
        private String version;
        private String type;        // jdk, jre, etc.
        private String installerType;       // .tar.gz, .msi, etc.
        private String os;
        private String arch;

        public String getDistro() {
            return distro;
        }

        public JavaInstaller setDistro(String distro) {
            this.distro = distro;
            return this;
        }

        public String getDownloadUrl() {
            return downloadUrl;
        }

        public JavaInstaller setDownloadUrl(String downloadUrl) {
            this.downloadUrl = downloadUrl;
            return this;
        }

        public String getName() {
            return name;
        }

        public JavaInstaller setName(String name) {
            this.name = name;
            return this;
        }

        public Integer getMajorVersion() {
            return majorVersion;
        }

        public JavaInstaller setMajorVersion(Integer majorVersion) {
            this.majorVersion = majorVersion;
            return this;
        }

        public Integer getMinorVersion() {
            return minorVersion;
        }

        public JavaInstaller setMinorVersion(Integer minorVersion) {
            this.minorVersion = minorVersion;
            return this;
        }

        public Integer getPatchVersion() {
            return patchVersion;
        }

        public JavaInstaller setPatchVersion(Integer patchVersion) {
            this.patchVersion = patchVersion;
            return this;
        }

        public String getVersion() {
            return version;
        }

        public JavaInstaller setVersion(String version) {
            this.version = version;
            return this;
        }

        public String getType() {
            return type;
        }

        public JavaInstaller setType(String type) {
            this.type = type;
            return this;
        }

        public String getInstallerType() {
            return installerType;
        }

        public JavaInstaller setInstallerType(String installerType) {
            this.installerType = installerType;
            return this;
        }

        public String getOs() {
            return os;
        }

        public JavaInstaller setOs(String os) {
            this.os = os;
            return this;
        }

        public String getArch() {
            return arch;
        }

        public JavaInstaller setArch(String arch) {
            this.arch = arch;
            return this;
        }

    }

}