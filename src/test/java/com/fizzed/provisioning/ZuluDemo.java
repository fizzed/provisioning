package com.fizzed.provisioning;

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
    static private final Logger log = LoggerFactory.getLogger(LibericaDemo.class);

    static public void main(String[] args) throws Exception {
        ZuluClient client = new ZuluClient();

        List<ZuluJavaRelease> javaReleases = client.getReleases(7);

        for (ZuluJavaRelease javaRelease : javaReleases) {
            log.info("{}", ToStringBuilder.reflectionToString(javaRelease, ToStringStyle.MULTI_LINE_STYLE));
        }
    }

}