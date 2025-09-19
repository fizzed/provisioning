package com.fizzed.provisioning.java;

import org.apache.commons.lang3.StringUtils;

public enum InstallerType {

    TAR_GZ(".tar.gz"),
    ZIP(".zip"),
    MSI(".msi"),
    PKG(".pkg"),
    DMG(".dmg"),
    RPM(".rpm"),
    APK(".apk"),
    DEB(".deb");

    private final String fileExtension;

    InstallerType(String fileExtension) {
        this.fileExtension = fileExtension;
    }

    public String getFileExtension() {
        return fileExtension;
    }

    static public InstallerType fromFileName(String name) {
        for (InstallerType installerType : InstallerType.values()) {
            if (StringUtils.endsWithIgnoreCase(name, installerType.fileExtension)) {
                return installerType;
            }
        }
        return null;
    }

}