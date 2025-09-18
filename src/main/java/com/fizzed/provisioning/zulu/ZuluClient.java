package com.fizzed.provisioning.zulu;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.SerializationFeature;
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

public class ZuluClient {
    static private final Logger log = LoggerFactory.getLogger(ZuluClient.class);

    private final ObjectMapper objectMapper;

    public ZuluClient() {
        this.objectMapper = new ObjectMapper();
        this.objectMapper.enable(SerializationFeature.INDENT_OUTPUT);
        this.objectMapper.setPropertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE);
    }

    public List<ZuluJavaRelease> getReleases(int javaMajorVersion) throws IOException, InterruptedException {
        final HttpClient httpClient = HttpClient.newHttpClient();
        final HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create("https://api.azul.com/metadata/v1/zulu/packages?java_version=" + javaMajorVersion))
            .build();

        final String responseJson = httpClient.send(request, HttpResponse.BodyHandlers.ofString())
            .body();

        log.info("{}", prettyPrintJson(this.objectMapper, responseJson));

        return this.objectMapper.readValue(responseJson, new TypeReference<List<ZuluJavaRelease>>() {});
    }

    public JavaInstaller toInstaller(ZuluJavaRelease javaRelease) {
        NativeTarget nativeTarget = ProvisioningHelper.detectFromText(javaRelease.getName());
        if (nativeTarget.getOperatingSystem() == null || nativeTarget.getHardwareArchitecture() == null) {
            if (javaRelease.getName().contains("x86lx64")) {
                return null;
            }
            if (javaRelease.getName().contains("solaris")) {
                return null;
            }
            if (javaRelease.getName().contains("ppc64")) {
                return null;
            }
            if (javaRelease.getName().contains("-win64")) {
                nativeTarget = ProvisioningHelper.detectFromText("windows x64");
            } else if (javaRelease.getName().contains("-macosx")) {
                nativeTarget = ProvisioningHelper.detectFromText("macos x64");
            } else {
                throw new RuntimeException("Failed to detect os / arch from " + javaRelease.getName());
            }
        }

        JavaInstaller installer = new JavaInstaller();
        installer.setDistro(JavaDistro.ZULU);
        installer.setName(javaRelease.getName());
        installer.setInstallerType(InstallerType.fromFileName(javaRelease.getName()));
        installer.setOs(nativeTarget.getOperatingSystem());
        installer.setArch(nativeTarget.getHardwareArchitecture());
        installer.setAbi(nativeTarget.getAbi());
        installer.setDownloadUrl(javaRelease.getDownloadUrl());

        // distroVersion={25,28,85,0}
        // downloadUrl=https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-linux_x64.zip
        installer.setVersion(new JavaVersion(null, javaRelease.getJavaVersion()[0], javaRelease.getJavaVersion()[1], javaRelease.getJavaVersion()[2], javaRelease.getOpenjdkBuildNumber()));

        // image types represent
        // -ca-crac-jdk
        if (javaRelease.getName().contains("-ca-crac-jdk") || javaRelease.getName().contains("-ca-crac-jre") || javaRelease.getName().contains("-ca-fx-jre")
                || javaRelease.getName().contains("-ca-fx-jdk") || javaRelease.getName().contains("-ca-hl-jdk") || javaRelease.getName().contains("-ca-hl-jre")
                || javaRelease.getName().contains("-ca-cp1-jre") || javaRelease.getName().contains("-ca-cp2-jre") || javaRelease.getName().contains("-ca-cp3-jre")) {
            installer.setImageType(ImageType.OTHER);
        } else if (javaRelease.getName().contains("-ca-jdk")) {
            installer.setImageType(ImageType.JDK);
        } else if (javaRelease.getName().contains("-ca-jre")) {
            installer.setImageType(ImageType.JRE);
        } else if (javaRelease.getName().contains("-win64") || javaRelease.getName().contains("-macosx")) {
            // odd example https://cdn.azul.com/zulu/bin/zulu1.7.0_79-7.9.0.2-win64.msi
            installer.setImageType(ImageType.OTHER);
        } else {
            throw new RuntimeException("Undetected image type from name " + javaRelease.getName());
        }

        return installer;
    }

}