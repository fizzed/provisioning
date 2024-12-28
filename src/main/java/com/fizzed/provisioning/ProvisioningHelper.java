package com.fizzed.provisioning;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;

public class ProvisioningHelper {

    static public String prettyPrintJson(ObjectMapper objectMapper, String json) throws IOException {
        JsonNode node = objectMapper.readTree(json);
        return objectMapper.writeValueAsString(node);
    }

}