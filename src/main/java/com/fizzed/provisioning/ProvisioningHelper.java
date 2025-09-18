package com.fizzed.provisioning;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fizzed.crux.jackson.EnumDeserializeStrategy;
import com.fizzed.crux.jackson.EnumSerializeStrategy;
import com.fizzed.crux.jackson.EnumStrategyModule;
import com.fizzed.jne.ABI;
import com.fizzed.jne.HardwareArchitecture;
import com.fizzed.jne.NativeTarget;
import com.fizzed.jne.OperatingSystem;
import org.apache.commons.lang3.StringUtils;

import java.io.IOException;

public class ProvisioningHelper {

    static private final ObjectMapper OBJECT_MAPPER;
    static {
        OBJECT_MAPPER = new ObjectMapper();
        OBJECT_MAPPER.registerModule(new EnumStrategyModule(EnumSerializeStrategy.LOWER_CASE, EnumDeserializeStrategy.IGNORE_CASE));
        OBJECT_MAPPER.enable(SerializationFeature.INDENT_OUTPUT);
        OBJECT_MAPPER.setPropertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE);
    }

    static public ObjectMapper getObjectMapper() {
        return OBJECT_MAPPER;
    }

    static public String prettyPrintJson(ObjectMapper objectMapper, String json) throws IOException {
        JsonNode node = objectMapper.readTree(json);
        return objectMapper.writeValueAsString(node);
    }

    public static NativeTarget detectFromText(String text) {
        OperatingSystem detectedOs = null;
        for (OperatingSystem os : OperatingSystem.values()) {
            if (StringUtils.containsIgnoreCase(text, os.name())) {
                detectedOs = os;
                break;
            }
            if (os.getAliases() != null) {
                for (String alias : os.getAliases()) {
                    if (StringUtils.containsIgnoreCase(text, alias)) {
                        detectedOs = os;
                        break;
                    }
                }
            }
        }

        HardwareArchitecture detectedArch = null;
        for (HardwareArchitecture arch : HardwareArchitecture.values()) {
            if (StringUtils.containsIgnoreCase(text, arch.name())) {
                detectedArch = arch;
                break;
            }
            if (arch.getAliases() != null) {
                for (String alias : arch.getAliases()) {
                    if (StringUtils.containsIgnoreCase(text, alias)) {
                        detectedArch = arch;
                        break;
                    }
                }
            }
        }

        ABI detectedABI = null;
        for (ABI abi : ABI.values()) {
            if (StringUtils.containsIgnoreCase(text, abi.name())) {
                detectedABI = abi;
                break;
            }
        }

        if (detectedOs == null) {
            if (StringUtils.containsIgnoreCase(text, "win")) {
                detectedOs = OperatingSystem.WINDOWS;
            } else if (StringUtils.containsIgnoreCase(text, "mac")) {
                detectedOs = OperatingSystem.MACOS;
            }
        }

        if (detectedArch == null) {
            if (StringUtils.containsIgnoreCase(text, "arm32-vfp-hflt")) {
                detectedArch = HardwareArchitecture.ARMHF;
            } else if (StringUtils.containsIgnoreCase(text, "aarch32hf")) {
                detectedArch = HardwareArchitecture.ARMHF;
            } else if (StringUtils.containsIgnoreCase(text, "aarch32sf")) {
                detectedArch = HardwareArchitecture.ARMEL;
            }
        }

        return NativeTarget.of(detectedOs, detectedArch, detectedABI);
    }

}