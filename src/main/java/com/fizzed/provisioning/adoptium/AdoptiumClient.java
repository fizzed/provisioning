package com.fizzed.provisioning.adoptium;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fizzed.jne.ABI;
import com.fizzed.jne.HardwareArchitecture;
import com.fizzed.jne.JavaVersion;
import com.fizzed.jne.NativeTarget;
import com.fizzed.provisioning.ProvisioningHelper;
import com.fizzed.provisioning.java.ImageType;
import com.fizzed.provisioning.java.InstallerType;
import com.fizzed.provisioning.java.JavaDistro;
import com.fizzed.provisioning.java.JavaInstaller;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.List;

import static com.fizzed.provisioning.ProvisioningHelper.prettyPrintJson;
import static java.util.Optional.ofNullable;

public class AdoptiumClient {
    static private final Logger log = LoggerFactory.getLogger(AdoptiumClient.class);

    private final ObjectMapper objectMapper;

    public AdoptiumClient() {
        this.objectMapper = new ObjectMapper();
        this.objectMapper.enable(SerializationFeature.INDENT_OUTPUT);
        this.objectMapper.setPropertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE);
    }

    public List<AdoptiumJavaReleases> getReleases(int javaMajorVersion) throws IOException, InterruptedException {
        final HttpClient httpClient = HttpClient.newBuilder().build();
        final HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create("https://api.adoptium.net/v3/assets/feature_releases/" + javaMajorVersion + "/ga"))
            .build();

        final String responseJson = httpClient.send(request, HttpResponse.BodyHandlers.ofString())
            .body();

        log.trace("{}", prettyPrintJson(this.objectMapper, responseJson));

        return this.objectMapper.readValue(responseJson, new TypeReference<>() {});
    }

    public JavaInstaller toInstaller(AdoptiumJavaRelease javaRelease) {
        NativeTarget nativeTarget = ProvisioningHelper.detectFromText(javaRelease.getOs() + " " + javaRelease.getArchitecture());
        if (nativeTarget.getOperatingSystem() == null || nativeTarget.getHardwareArchitecture() == null) {
            if ("arm".equals(javaRelease.getArchitecture())) {
                nativeTarget = NativeTarget.of(nativeTarget.getOperatingSystem(), HardwareArchitecture.ARMHF, nativeTarget.getAbi());
            } else {
                throw new RuntimeException("Failed to detect os / arch from " + javaRelease.getPkg().getName());
            }
        }

        if (javaRelease.getOs().equals("alpine-linux")) {
            // we detect MUSL here...
            nativeTarget = NativeTarget.of(nativeTarget.getOperatingSystem(), nativeTarget.getHardwareArchitecture(), ABI.MUSL);
        }

        JavaInstaller installer = new JavaInstaller();
        installer.setDistro(JavaDistro.TEMURIN);
        installer.setName(javaRelease.getPkg().getName());
        installer.setInstallerType(InstallerType.fromFileName(javaRelease.getPkg().getName()));
        installer.setOs(nativeTarget.getOperatingSystem());
        installer.setArch(nativeTarget.getHardwareArchitecture());
        installer.setAbi(nativeTarget.getAbi());
        installer.setDownloadUrl(javaRelease.getPkg().getLink());

        // the java version is not included very well by default
        // scm ref is interesting to try and use
        // scmRef=jdk-21.0.1+12_adopt
        String versionString = javaRelease.getScmRef();
        versionString = versionString.replace("jdk-", "");
        versionString = versionString.replace("_adopt", "");
        installer.setVersion(JavaVersion.parse(versionString));

        // image types represent
        // jvmImpl of "hotspot" are the only ones we want
        if (!javaRelease.getJvmImpl().equals("hotspot")) {
            throw new RuntimeException("Unsupported jvmImpl " + javaRelease.getJvmImpl());
        }

        /*Full version of Liberica includes LibericaFX, which is based on OpenJFX and Minimal VM, where suitable.
        Standard version is best suited for server and desktop deployments that do not require any additional components.
        Lite version of Liberica works best for cloud deployments and is optimized for size.
        Liberica JDK with CRaC is the build of Liberica JDK that supports the CRaC API. It allows making and utilizing the snapshots of app. This flavor is not TCK verified.*/
        switch (ofNullable(javaRelease.getImageType()).map(String::toLowerCase).orElse("")) {
            case "jdk":
                installer.setImageType(ImageType.JDK);
                break;
            case "jre":
                installer.setImageType(ImageType.JRE);
                break;
            case "debugimage":
            case "testimage":
            case "sources":
            case "staticlibs":              // ??
            case "sbom":                    // ??
                // these are images we really don't want to bother with
                installer.setImageType(ImageType.OTHER);
                break;
            default:
                throw new RuntimeException("Unsupported image type " + javaRelease.getImageType());
        }

        return installer;
    }

}