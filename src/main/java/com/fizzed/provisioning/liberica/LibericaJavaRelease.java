package com.fizzed.provisioning.liberica;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * {
 *   "bitness" : 32,
 *   "latestLTS" : true,
 *   "updateVersion" : 2,
 *   "downloadUrl" : "https://github.com/bell-sw/Liberica/releases/download/21.0.2+14/bellsoft-jre21.0.2+14-windows-i586.zip",
 *   "latestInFeatureVersion" : false,
 *   "LTS" : true,
 *   "bundleType" : "jre",
 *   "featureVersion" : 21,
 *   "packageType" : "zip",
 *   "FX" : false,
 *   "GA" : true,
 *   "architecture" : "x86",
 *   "latest" : false,
 *   "extraVersion" : 0,
 *   "buildVersion" : 14,
 *   "EOL" : true,
 *   "os" : "windows",
 *   "interimVersion" : 0,
 *   "version" : "21.0.2+14",
 *   "sha1" : "610dd75fc7a467c42e19264cda56babdb2bd9828",
 *   "filename" : "bellsoft-jre21.0.2+14-windows-i586.zip",
 *   "installationType" : "archive",
 *   "size" : 48351718,
 *   "patchVersion" : 0,
 *   "TCK" : true,
 *   "updateType" : "psu"
 * }
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class LibericaJavaRelease {

    private Integer bitness;
    private Integer updateVersion;
    private String downloadUrl;
    private String bundleType;
    private Integer featureVersion;
    private String packageType;
    private String architecture;
    private Integer extraVersion;
    private Integer buildVersion;
    private String os;
    private Integer interimVersion;
    private String version;
    private Integer patchVersion;
    private String filename;

    public String getFilename() {
        return filename;
    }

    public LibericaJavaRelease setFilename(String filename) {
        this.filename = filename;
        return this;
    }

    public Integer getBitness() {
        return bitness;
    }

    public LibericaJavaRelease setBitness(Integer bitness) {
        this.bitness = bitness;
        return this;
    }

    public Integer getUpdateVersion() {
        return updateVersion;
    }

    public LibericaJavaRelease setUpdateVersion(Integer updateVersion) {
        this.updateVersion = updateVersion;
        return this;
    }

    public String getDownloadUrl() {
        return downloadUrl;
    }

    public LibericaJavaRelease setDownloadUrl(String downloadUrl) {
        this.downloadUrl = downloadUrl;
        return this;
    }

    public String getBundleType() {
        return bundleType;
    }

    public LibericaJavaRelease setBundleType(String bundleType) {
        this.bundleType = bundleType;
        return this;
    }

    public Integer getFeatureVersion() {
        return featureVersion;
    }

    public LibericaJavaRelease setFeatureVersion(Integer featureVersion) {
        this.featureVersion = featureVersion;
        return this;
    }

    public String getPackageType() {
        return packageType;
    }

    public LibericaJavaRelease setPackageType(String packageType) {
        this.packageType = packageType;
        return this;
    }

    public String getArchitecture() {
        return architecture;
    }

    public LibericaJavaRelease setArchitecture(String architecture) {
        this.architecture = architecture;
        return this;
    }

    public Integer getExtraVersion() {
        return extraVersion;
    }

    public LibericaJavaRelease setExtraVersion(Integer extraVersion) {
        this.extraVersion = extraVersion;
        return this;
    }

    public Integer getBuildVersion() {
        return buildVersion;
    }

    public LibericaJavaRelease setBuildVersion(Integer buildVersion) {
        this.buildVersion = buildVersion;
        return this;
    }

    public String getOs() {
        return os;
    }

    public LibericaJavaRelease setOs(String os) {
        this.os = os;
        return this;
    }

    public Integer getInterimVersion() {
        return interimVersion;
    }

    public LibericaJavaRelease setInterimVersion(Integer interimVersion) {
        this.interimVersion = interimVersion;
        return this;
    }

    public String getVersion() {
        return version;
    }

    public LibericaJavaRelease setVersion(String version) {
        this.version = version;
        return this;
    }

    public Integer getPatchVersion() {
        return patchVersion;
    }

    public LibericaJavaRelease setPatchVersion(Integer patchVersion) {
        this.patchVersion = patchVersion;
        return this;
    }

}