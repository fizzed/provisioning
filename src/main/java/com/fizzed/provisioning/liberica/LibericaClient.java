package com.fizzed.provisioning.liberica;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fizzed.jne.NativeTarget;
import com.fizzed.provisioning.ProvisioningHelper;
import com.fizzed.provisioning.java.InstallerType;
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
        installer.setDistro("liberica");
        installer.setName(javaRelease.getFilename());
        installer.setInstallerType(InstallerType.fromFileName(javaRelease.getFilename()));
        installer.setOs(nativeTarget.getOperatingSystem());
        installer.setArch(nativeTarget.getHardwareArchitecture());
        installer.setAbi(nativeTarget.getAbi());
        installer.setDownloadUrl(javaRelease.getDownloadUrl());
        installer.setMajorVersion(javaRelease.getFeatureVersion());
        installer.setMinorVersion(javaRelease.getInterimVersion());
        installer.setPatchVersion(javaRelease.getPatchVersion());

        return installer;
    }

}