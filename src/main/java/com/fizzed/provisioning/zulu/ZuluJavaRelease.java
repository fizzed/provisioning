package com.fizzed.provisioning.zulu;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * {
 *   "availability_type" : "CA",
 *   "distro_version" : [ 21, 38, 21, 0 ],
 *   "download_url" : "https://cdn.azul.com/zulu/bin/zulu21.38.21-ca-crac-jre21.0.5-linux_x64.tar.gz",
 *   "java_version" : [ 21, 0, 5 ],
 *   "latest" : true,
 *   "name" : "zulu21.38.21-ca-crac-jre21.0.5-linux_x64.tar.gz",
 *   "openjdk_build_number" : 11,
 *   "package_uuid" : "1c80f4f5-7a2c-4184-9fb9-cd7737b83bf6",
 *   "product" : "zulu"
 * }
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class ZuluJavaRelease {

    private String availabilityType;
    private Integer[] distroVersion;
    private String downloadUrl;
    private Integer[] javaVersion;
    private Boolean latest;
    private String name;
    private Integer openjdkBuildNumber;
    private String packageUuid;
    private String product;

    public String getAvailabilityType() {
        return availabilityType;
    }

    public ZuluJavaRelease setAvailabilityType(String availabilityType) {
        this.availabilityType = availabilityType;
        return this;
    }

    public Integer[] getDistroVersion() {
        return distroVersion;
    }

    public ZuluJavaRelease setDistroVersion(Integer[] distroVersion) {
        this.distroVersion = distroVersion;
        return this;
    }

    public String getDownloadUrl() {
        return downloadUrl;
    }

    public ZuluJavaRelease setDownloadUrl(String downloadUrl) {
        this.downloadUrl = downloadUrl;
        return this;
    }

    public Integer[] getJavaVersion() {
        return javaVersion;
    }

    public ZuluJavaRelease setJavaVersion(Integer[] javaVersion) {
        this.javaVersion = javaVersion;
        return this;
    }

    public Boolean getLatest() {
        return latest;
    }

    public ZuluJavaRelease setLatest(Boolean latest) {
        this.latest = latest;
        return this;
    }

    public String getName() {
        return name;
    }

    public ZuluJavaRelease setName(String name) {
        this.name = name;
        return this;
    }

    public Integer getOpenjdkBuildNumber() {
        return openjdkBuildNumber;
    }

    public ZuluJavaRelease setOpenjdkBuildNumber(Integer openjdkBuildNumber) {
        this.openjdkBuildNumber = openjdkBuildNumber;
        return this;
    }

    public String getPackageUuid() {
        return packageUuid;
    }

    public ZuluJavaRelease setPackageUuid(String packageUuid) {
        this.packageUuid = packageUuid;
        return this;
    }

    public String getProduct() {
        return product;
    }

    public ZuluJavaRelease setProduct(String product) {
        this.product = product;
        return this;
    }
}