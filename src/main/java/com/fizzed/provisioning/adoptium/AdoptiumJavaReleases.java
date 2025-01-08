package com.fizzed.provisioning.adoptium;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class AdoptiumJavaReleases {

    private String aqavitResultsLink;
    private List<AdoptiumJavaRelease> binaries;

    public String getAqavitResultsLink() {
        return aqavitResultsLink;
    }

    public AdoptiumJavaReleases setAqavitResultsLink(String aqavitResultsLink) {
        this.aqavitResultsLink = aqavitResultsLink;
        return this;
    }

    public List<AdoptiumJavaRelease> getBinaries() {
        return binaries;
    }

    public AdoptiumJavaReleases setBinaries(List<AdoptiumJavaRelease> binaries) {
        this.binaries = binaries;
        return this;
    }

}