package com.fizzed.provisioning.java;

import com.fizzed.jne.ABI;
import com.fizzed.jne.HardwareArchitecture;
import com.fizzed.jne.JavaVersion;
import com.fizzed.jne.OperatingSystem;

public class JavaInstaller {

    private JavaDistro distro;
    private String downloadUrl;
    private String name;
    private JavaVersion version;
    private ImageType imageType;        // jdk, jre, etc.
    private InstallerType installerType;       // .tar.gz, .msi, etc.
    private OperatingSystem os;
    private HardwareArchitecture arch;
    private ABI abi;

    public JavaDistro getDistro() {
        return distro;
    }

    public JavaInstaller setDistro(JavaDistro distro) {
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

    public JavaVersion getVersion() {
        return version;
    }

    public JavaInstaller setVersion(JavaVersion version) {
        this.version = version;
        return this;
    }

    public ImageType getImageType() {
        return imageType;
    }

    public JavaInstaller setImageType(ImageType imageType) {
        this.imageType = imageType;
        return this;
    }

    public InstallerType getInstallerType() {
        return installerType;
    }

    public JavaInstaller setInstallerType(InstallerType installerType) {
        this.installerType = installerType;
        return this;
    }

    public OperatingSystem getOs() {
        return os;
    }

    public JavaInstaller setOs(OperatingSystem os) {
        this.os = os;
        return this;
    }

    public HardwareArchitecture getArch() {
        return arch;
    }

    public JavaInstaller setArch(HardwareArchitecture arch) {
        this.arch = arch;
        return this;
    }

    public ABI getAbi() {
        return abi;
    }

    public JavaInstaller setAbi(ABI abi) {
        this.abi = abi;
        return this;
    }

}