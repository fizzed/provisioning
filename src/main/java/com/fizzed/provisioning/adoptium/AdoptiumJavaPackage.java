package com.fizzed.provisioning.adoptium;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * {
 *       "checksum" : "41298356047825d6ebf6bdf6e754d1a507c20ef5ffcebf7466933c4c2a7e7d84",
 *       "download_count" : 29,
 *       "link" : "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-sbom_aarch64_linux_hotspot_21.0.5_11.json",
 *       "name" : "OpenJDK21U-sbom_aarch64_linux_hotspot_21.0.5_11.json",
 *       "signature_link" : "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-sbom_aarch64_linux_hotspot_21.0.5_11.json.sig",
 *       "size" : 47059
 * }
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class AdoptiumJavaPackage {

    private String link;
    private String name;

    public String getLink() {
        return link;
    }

    public AdoptiumJavaPackage setLink(String link) {
        this.link = link;
        return this;
    }

    public String getName() {
        return name;
    }

    public AdoptiumJavaPackage setName(String name) {
        this.name = name;
        return this;
    }

    @Override
    public String toString() {
        return "AdoptiumJavaPackage{" +
            "link='" + link + '\'' +
            ", name='" + name + '\'' +
            '}';
    }
}