package com.fizzed.provisioning;

import com.fizzed.jne.NativeTarget;
import com.fizzed.provisioning.adoptium.AdoptiumClient;
import com.fizzed.provisioning.adoptium.AdoptiumJavaRelease;
import com.fizzed.provisioning.adoptium.AdoptiumJavaReleases;
import com.fizzed.provisioning.java.JavaInstaller;
import com.fizzed.provisioning.liberica.LibericaClient;
import com.fizzed.provisioning.liberica.LibericaJavaRelease;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

class AdoptiumDemo {
    static private final Logger log = LoggerFactory.getLogger(AdoptiumDemo.class);

    static public void main(String[] args) throws Exception {
        AdoptiumClient client = new AdoptiumClient();

        List<AdoptiumJavaReleases> javaReleases1 = client.getReleases(25);

        for (AdoptiumJavaReleases javaReleases : javaReleases1) {
            for (AdoptiumJavaRelease javaRelease : javaReleases.getBinaries()) {
                log.info("{}", ToStringBuilder.reflectionToString(javaRelease, ToStringStyle.MULTI_LINE_STYLE));

                JavaInstaller javaInstaller = client.toInstaller(javaRelease);

                log.info("{}", ProvisioningHelper.getObjectMapper().writeValueAsString(javaInstaller));
            }
        }
    }

}