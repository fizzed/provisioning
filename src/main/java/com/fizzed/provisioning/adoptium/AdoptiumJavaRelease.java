package com.fizzed.provisioning.adoptium;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * {
 *     "architecture" : "aarch64",
 *     "download_count" : 29,
 *     "heap_size" : "normal",
 *     "image_type" : "sbom",
 *     "jvm_impl" : "hotspot",
 *     "os" : "linux",
 *     "package" : {
 *       "checksum" : "41298356047825d6ebf6bdf6e754d1a507c20ef5ffcebf7466933c4c2a7e7d84",
 *       "download_count" : 29,
 *       "link" : "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-sbom_aarch64_linux_hotspot_21.0.5_11.json",
 *       "name" : "OpenJDK21U-sbom_aarch64_linux_hotspot_21.0.5_11.json",
 *       "signature_link" : "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-sbom_aarch64_linux_hotspot_21.0.5_11.json.sig",
 *       "size" : 47059
 *     },
 *     "project" : "jdk",
 *     "scm_ref" : "jdk-21.0.5+11_adopt",
 *     "updated_at" : "2024-10-16T16:35:00Z"
 * }
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class AdoptiumJavaRelease {

    private String architecture;
    private String heapSize;
    private String imageType;
    private String jvmImpl;
    private String os;
    private String project;
    private String scmRef;
    @JsonProperty("package")
    private AdoptiumJavaPackage pkg;

    public String getArchitecture() {
        return architecture;
    }

    public AdoptiumJavaRelease setArchitecture(String architecture) {
        this.architecture = architecture;
        return this;
    }

    public String getHeapSize() {
        return heapSize;
    }

    public AdoptiumJavaRelease setHeapSize(String heapSize) {
        this.heapSize = heapSize;
        return this;
    }

    public String getImageType() {
        return imageType;
    }

    public AdoptiumJavaRelease setImageType(String imageType) {
        this.imageType = imageType;
        return this;
    }

    public String getJvmImpl() {
        return jvmImpl;
    }

    public AdoptiumJavaRelease setJvmImpl(String jvmImpl) {
        this.jvmImpl = jvmImpl;
        return this;
    }

    public String getOs() {
        return os;
    }

    public AdoptiumJavaRelease setOs(String os) {
        this.os = os;
        return this;
    }

    public String getProject() {
        return project;
    }

    public AdoptiumJavaRelease setProject(String project) {
        this.project = project;
        return this;
    }

    public String getScmRef() {
        return scmRef;
    }

    public AdoptiumJavaRelease setScmRef(String scmRef) {
        this.scmRef = scmRef;
        return this;
    }

    public AdoptiumJavaPackage getPkg() {
        return pkg;
    }

    public AdoptiumJavaRelease setPkg(AdoptiumJavaPackage pkg) {
        this.pkg = pkg;
        return this;
    }

}