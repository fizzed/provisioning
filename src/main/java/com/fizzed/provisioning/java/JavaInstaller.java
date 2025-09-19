package com.fizzed.provisioning.java;

import com.fizzed.jne.ABI;
import com.fizzed.jne.HardwareArchitecture;
import com.fizzed.jne.JavaVersion;
import com.fizzed.jne.OperatingSystem;
import org.apache.commons.lang3.ObjectUtils;

import java.util.Comparator;
import java.util.Objects;

import static com.fizzed.crux.util.Maybe.maybe;

public class JavaInstaller implements Comparable<JavaInstaller> {

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

    @Override
    public final boolean equals(Object o) {
        if (!(o instanceof JavaInstaller)) return false;

        JavaInstaller installer = (JavaInstaller) o;
        return distro == installer.distro && Objects.equals(downloadUrl, installer.downloadUrl) && Objects.equals(name, installer.name) && Objects.equals(version, installer.version) && imageType == installer.imageType && installerType == installer.installerType && os == installer.os && arch == installer.arch && abi == installer.abi;
    }

    @Override
    public int hashCode() {
        int result = Objects.hashCode(distro);
        result = 31 * result + Objects.hashCode(downloadUrl);
        result = 31 * result + Objects.hashCode(name);
        result = 31 * result + Objects.hashCode(version);
        result = 31 * result + Objects.hashCode(imageType);
        result = 31 * result + Objects.hashCode(installerType);
        result = 31 * result + Objects.hashCode(os);
        result = 31 * result + Objects.hashCode(arch);
        result = 31 * result + Objects.hashCode(abi);
        return result;
    }

    @Override
    public int compareTo(JavaInstaller o2) {
        return COMPARATOR.compare(this, o2);
    }

    static public final Comparator<JavaInstaller> COMPARATOR = (o1, o2) -> {
        int c = o1.getDistro().compareTo(o2.getDistro());
        if (c == 0) {
            // natural ordering of version is higher first
            c = ObjectUtils.compare(o2.getVersion(), o1.getVersion(), false);
            if (c == 0) {
                c = lowerCaseCompareTo(o1.getOs(), o2.getOs());
                if (c == 0) {
                    c = lowerCaseCompareTo(o1.getArch(), o2.getArch());
                    if (c == 0) {
                        c = ObjectUtils.compare(o1.getAbi(), o2.getAbi(), false);
                        if (c == 0) {
                            c = lowerCaseCompareTo(o1.getImageType(), o2.getImageType());
                            if (c == 0) {
                                c = lowerCaseCompareTo(o1.getInstallerType(), o2.getInstallerType());
                                if (c == 0) {
                                    c = o1.getName().compareTo(o2.getName());
                                }
                            }
                        }
                    }
                }
            }
        }
        return c;
    };

    static private int lowerCaseCompareTo(Object o1, Object o2) {
        String s1 = maybe(o1).map(Object::toString).map(String::toLowerCase).orNull();
        String s2 = maybe(o2).map(Object::toString).map(String::toLowerCase).orNull();
        return ObjectUtils.compare(s1, s2, false);
    }

}