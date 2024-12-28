package com.fizzed.provisioning.liberica;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.List;

import static com.fizzed.provisioning.ProvisioningHelper.prettyPrintJson;

public class LibericaClient {
    static private final Logger log = LoggerFactory.getLogger(LibericaClient.class);

    private final ObjectMapper objectMapper;

    public LibericaClient() {
        this.objectMapper = new ObjectMapper();
        this.objectMapper.enable(SerializationFeature.INDENT_OUTPUT);
    }

    public List<LibericaJavaRelease> getReleases(int javaMajorVersion) throws IOException, InterruptedException {
        final HttpClient httpClient = HttpClient.newHttpClient();
        final HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create("https://api.bell-sw.com/v1/liberica/releases?version-feature=" + javaMajorVersion))
            .build();

        final String responseJson = httpClient.send(request, HttpResponse.BodyHandlers.ofString())
            .body();

        //log.info("{}", prettyPrintJson(this.objectMapper, responseJson));

        return this.objectMapper.readValue(responseJson, new TypeReference<List<LibericaJavaRelease>>() {});
    }

}