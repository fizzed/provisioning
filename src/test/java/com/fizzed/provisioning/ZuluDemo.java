package com.fizzed.provisioning;

import com.fizzed.jne.NativeTarget;
import com.fizzed.provisioning.java.JavaInstaller;
import com.fizzed.provisioning.liberica.LibericaClient;
import com.fizzed.provisioning.liberica.LibericaJavaRelease;
import com.fizzed.provisioning.zulu.ZuluClient;
import com.fizzed.provisioning.zulu.ZuluJavaRelease;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

class ZuluDemo {
    static private final Logger log = LoggerFactory.getLogger(ZuluDemo.class);

    static public void main(String[] args) throws Exception {
        ZuluClient client = new ZuluClient();

        List<ZuluJavaRelease> javaReleases = client.getReleases(21);

        for (ZuluJavaRelease javaRelease : javaReleases) {
            log.info("{}", ToStringBuilder.reflectionToString(javaRelease, ToStringStyle.MULTI_LINE_STYLE));

            JavaInstaller javaInstaller = client.toInstaller(javaRelease);

            log.info("{}", ToStringBuilder.reflectionToString(javaInstaller, ToStringStyle.MULTI_LINE_STYLE));

            if (javaInstaller.getInstallerType() == null) {
                throw new RuntimeException("Installer type is null");
            }

            /*NativeTarget nativeTarget = ProvisioningHelper.detectFromText(javaRelease.getName());
            if (nativeTarget.getOperatingSystem() == null || nativeTarget.getHardwareArchitecture() == null) {
                if (javaRelease.getName().contains("x86lx64")) {
                    break;
                }
                if (javaRelease.getName().contains("solaris")) {
                    break;
                }
                if (javaRelease.getName().contains("ppc64")) {
                    break;
                }
                throw new RuntimeException("Failed to detect os / arch from " + javaRelease.getName());
            }*/
        }
    }

}