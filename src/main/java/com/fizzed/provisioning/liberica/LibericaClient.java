package com.fizzed.provisioning.liberica;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fizzed.jne.JavaVersion;
import com.fizzed.jne.NativeTarget;
import com.fizzed.provisioning.ProvisioningHelper;
import com.fizzed.provisioning.java.ImageType;
import com.fizzed.provisioning.java.InstallerType;
import com.fizzed.provisioning.java.JavaDistro;
import com.fizzed.provisioning.java.JavaInstaller;
import com.fizzed.provisioning.zulu.ZuluJavaRelease;
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

public class LibericaClient {
    static private final Logger log = LoggerFactory.getLogger(LibericaClient.class);

    private final ObjectMapper objectMapper;

    public LibericaClient() {
        this.objectMapper = new ObjectMapper();
        this.objectMapper.enable(SerializationFeature.INDENT_OUTPUT);
    }

    public List<LibericaJavaRelease> getReleases(int javaMajorVersion) throws IOException, InterruptedException {
        final HttpClient httpClient = HttpClient.newHttpClient();
        final HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create("https://api.bell-sw.com/v1/liberica/releases?version-feature=" + javaMajorVersion))
            .build();

        final String responseJson = httpClient.send(request, HttpResponse.BodyHandlers.ofString())
            .body();

        //log.info("{}", prettyPrintJson(this.objectMapper, responseJson));

        return this.objectMapper.readValue(responseJson, new TypeReference<>() {});
    }

    public JavaInstaller toInstaller(LibericaJavaRelease javaRelease) {
        NativeTarget nativeTarget = ProvisioningHelper.detectFromText(javaRelease.getFilename());
        if (nativeTarget.getOperatingSystem() == null || nativeTarget.getHardwareArchitecture() == null) {
            if (javaRelease.getFilename().contains("-src")) {
                return null;
            }
            if (javaRelease.getFilename().contains("sparcv9")) {
                return null;
            }
            /*if (javaRelease.getName().contains("x86lx64")) {
                return null;
            }
            if (javaRelease.getName().contains("solaris")) {
                return null;
            }
            if (javaRelease.getName().contains("ppc64")) {
                return null;
            }*/
            throw new RuntimeException("Failed to detect os / arch from " + javaRelease.getFilename());
        }

        JavaInstaller installer = new JavaInstaller();
        installer.setDistro(JavaDistro.LIBERICA);
        installer.setName(javaRelease.getFilename());
        installer.setInstallerType(InstallerType.fromFileName(javaRelease.getFilename()));
        installer.setOs(nativeTarget.getOperatingSystem());
        installer.setArch(nativeTarget.getHardwareArchitecture());
        installer.setAbi(nativeTarget.getAbi());
        installer.setDownloadUrl(javaRelease.getDownloadUrl());
        installer.setVersion(new JavaVersion(
            javaRelease.getVersion(), javaRelease.getFeatureVersion(), javaRelease.getInterimVersion(), javaRelease.getUpdateVersion(), javaRelease.getBuildVersion()));

        // image types represent
        /*Full version of Liberica includes LibericaFX, which is based on OpenJFX and Minimal VM, where suitable.
        Standard version is best suited for server and desktop deployments that do not require any additional components.
        Lite version of Liberica works best for cloud deployments and is optimized for size.
        Liberica JDK with CRaC is the build of Liberica JDK that supports the CRaC API. It allows making and utilizing the snapshots of app. This flavor is not TCK verified.*/
        switch (ofNullable(javaRelease.getBundleType()).map(String::toLowerCase).orElse("")) {
            case "jdk":
                installer.setImageType(ImageType.JDK);
                break;
            case "jre":
                installer.setImageType(ImageType.JRE);
                break;
            case "jdk-full":
            case "jdk-lite":
            case "jre-full":
            case "jre-lite":
            case "jdk-crac":
                // these are images we really don't want to bother with
                installer.setImageType(ImageType.OTHER);
                break;
            default:
                throw new RuntimeException("Unsupported bundle type " + javaRelease.getBundleType());
        }

        return installer;
    }

}