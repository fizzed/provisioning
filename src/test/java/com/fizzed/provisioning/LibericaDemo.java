package com.fizzed.provisioning;

import org.apache.commons.lang3.builder.ToStringBuilder;
import com.fizzed.provisioning.liberica.LibericaClient;
import com.fizzed.provisioning.liberica.LibericaJavaRelease;
import org.apache.commons.lang3.builder.ToStringStyle;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

class LibericaDemo {
    static private final Logger log = LoggerFactory.getLogger(LibericaDemo.class);

    static public void main(String[] args) throws Exception {
        LibericaClient client = new LibericaClient();

        List<LibericaJavaRelease> javaReleases = client.getReleases(21);

        for (LibericaJavaRelease javaRelease : javaReleases) {
            log.info("{}", ToStringBuilder.reflectionToString(javaRelease, ToStringStyle.MULTI_LINE_STYLE));
        }
    }

}