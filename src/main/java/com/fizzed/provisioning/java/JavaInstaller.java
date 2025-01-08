package com.fizzed.provisioning.java;

import com.fizzed.jne.ABI;
import com.fizzed.jne.HardwareArchitecture;
import com.fizzed.jne.OperatingSystem;

import java.util.Comparator;

public class JavaInstaller {

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
    private String imageType;        // jdk, jre, etc.
    private InstallerType installerType;       // .tar.gz, .msi, etc.
    private OperatingSystem os;
    private HardwareArchitecture arch;
    private ABI abi;

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
        if (this.version == null) {
            if (this.majorVersion != null && this.minorVersion != null && this.patchVersion != null) {
                return this.majorVersion + "." + this.minorVersion + "." + this.patchVersion;
            }
        }
        return version;
    }

    public JavaInstaller setVersion(String version) {
        this.version = version;
        return this;
    }

    public String getImageType() {
        return imageType;
    }

    public JavaInstaller setImageType(String imageType) {
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