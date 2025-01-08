package com.fizzed.provisioning;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import static com.fizzed.provisioning.ProvisioningHelper.prettyPrintJson;

class HttpDemo {
    static private final Logger log = LoggerFactory.getLogger(LibericaDemo.class);

    static public void main(String[] args) throws Exception {
        final HttpClient httpClient = HttpClient.newHttpClient();

        final HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create("https://api.github.com/repos/corretto/corretto-21/releases"))
            .header("Accept", "application/vnd.github+json")
            .build();

        /*final HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create("https://api.adoptium.net/v3/assets/feature_releases/21/ga"))
            .header("Accept", "application/json")
            .build();*/

        final String responseJson = httpClient.send(request, HttpResponse.BodyHandlers.ofString())
            .body();

        final ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.enable(SerializationFeature.INDENT_OUTPUT);
        log.info("{}", prettyPrintJson(objectMapper, responseJson));
    }

}