package com.fizzed.provisioning.java;

import org.apache.commons.lang3.StringUtils;

public enum JavaDistro {

    ZULU("zulu"),
    TEMURIN("temurin"),
    LIBERICA("liberica"),
    NITRO("nitro");

    private final String name;

    JavaDistro(String name) {
        this.name = name;
    }

    public String getName() {
        return this.name;
    }

    static public JavaDistro fromName(String name) {
        for (JavaDistro distro : JavaDistro.values()) {
            if (StringUtils.equalsIgnoreCase(name, distro.name)) {
                return distro;
            }
        }
        return null;
    }

}