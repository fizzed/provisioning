package com.fizzed.provisioning;

import com.fizzed.jne.ABI;
import com.fizzed.jne.HardwareArchitecture;
import com.fizzed.jne.NativeTarget;
import com.fizzed.jne.OperatingSystem;
import org.junit.jupiter.api.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

class ProvisioningHelperTest {

    @Test
    void detectFromText() {
        NativeTarget nativeTarget;

        // zulu java examples
        nativeTarget = ProvisioningHelper.detectFromText("zulu7.56.0.11-ca-jre7.0.352-win_x64.msi");
        assertThat(nativeTarget.getOperatingSystem(), is(OperatingSystem.WINDOWS));
        assertThat(nativeTarget.getHardwareArchitecture(), is(HardwareArchitecture.X64));
        assertThat(nativeTarget.getAbi(), is(nullValue()));

        nativeTarget = ProvisioningHelper.detectFromText("zulu17.54.21-ca-jre17.0.13-c2-linux_aarch32hf.tar.gz");
        assertThat(nativeTarget.getOperatingSystem(), is(OperatingSystem.LINUX));
        assertThat(nativeTarget.getHardwareArchitecture(), is(HardwareArchitecture.ARMHF));
        assertThat(nativeTarget.getAbi(), is(nullValue()));

        nativeTarget = ProvisioningHelper.detectFromText("zulu11.76.21-ca-jdk11.0.25-linux_aarch32sf.tar.gz");
        assertThat(nativeTarget.getOperatingSystem(), is(OperatingSystem.LINUX));
        assertThat(nativeTarget.getHardwareArchitecture(), is(HardwareArchitecture.ARMEL));
        assertThat(nativeTarget.getAbi(), is(nullValue()));

        nativeTarget = ProvisioningHelper.detectFromText("zulu11.76.21-ca-jre11.0.25-solaris_sparcv9.zip");
        assertThat(nativeTarget.getOperatingSystem(), is(OperatingSystem.SOLARIS));
        //assertThat(nativeTarget.getHardwareArchitecture(), is(HardwareArchitecture.ARMEL));
        assertThat(nativeTarget.getAbi(), is(nullValue()));

        nativeTarget = ProvisioningHelper.detectFromText("zulu11.76.21-ca-jre11.0.25-solaris_sparcv9.zip");
        assertThat(nativeTarget.getOperatingSystem(), is(OperatingSystem.SOLARIS));
        //assertThat(nativeTarget.getHardwareArchitecture(), is(HardwareArchitecture.ARMEL));
        assertThat(nativeTarget.getAbi(), is(nullValue()));

        nativeTarget = ProvisioningHelper.detectFromText("zulu8.82.0.23-ca-hl-jdk8.0.432-linux_ppc64.tar.gz");
        assertThat(nativeTarget.getOperatingSystem(), is(OperatingSystem.LINUX));
        //assertThat(nativeTarget.getHardwareArchitecture(), is(HardwareArchitecture.ARMEL));
        assertThat(nativeTarget.getAbi(), is(nullValue()));

        // liberica java examples
        nativeTarget = ProvisioningHelper.detectFromText("bellsoft-jre21.0.2+14-windows-i586.zip");
        assertThat(nativeTarget.getOperatingSystem(), is(OperatingSystem.WINDOWS));
        assertThat(nativeTarget.getHardwareArchitecture(), is(HardwareArchitecture.X32));
        assertThat(nativeTarget.getAbi(), is(nullValue()));

        nativeTarget = ProvisioningHelper.detectFromText("bellsoft-jre21.0.2+14-macos-amd64.zip");
        assertThat(nativeTarget.getOperatingSystem(), is(OperatingSystem.MACOS));
        assertThat(nativeTarget.getHardwareArchitecture(), is(HardwareArchitecture.X64));
        assertThat(nativeTarget.getAbi(), is(nullValue()));

        nativeTarget = ProvisioningHelper.detectFromText("bellsoft-jre21.0.2+14-macos-aarch64.zip");
        assertThat(nativeTarget.getOperatingSystem(), is(OperatingSystem.MACOS));
        assertThat(nativeTarget.getHardwareArchitecture(), is(HardwareArchitecture.ARM64));
        assertThat(nativeTarget.getAbi(), is(nullValue()));

        nativeTarget = ProvisioningHelper.detectFromText("bellsoft-jre21.0.2+14-linux-x64-musl.apk");
        assertThat(nativeTarget.getOperatingSystem(), is(OperatingSystem.LINUX));
        assertThat(nativeTarget.getHardwareArchitecture(), is(HardwareArchitecture.X64));
        assertThat(nativeTarget.getAbi(), is(ABI.MUSL));

        nativeTarget = ProvisioningHelper.detectFromText("bellsoft-jre21.0.2+14-linux-riscv64.tar.gz");
        assertThat(nativeTarget.getOperatingSystem(), is(OperatingSystem.LINUX));
        assertThat(nativeTarget.getHardwareArchitecture(), is(HardwareArchitecture.RISCV64));
        assertThat(nativeTarget.getAbi(), is(nullValue()));

        nativeTarget = ProvisioningHelper.detectFromText("bellsoft-jre21.0.2+14-linux-arm32-vfp-hflt.tar.gz");
        assertThat(nativeTarget.getOperatingSystem(), is(OperatingSystem.LINUX));
        assertThat(nativeTarget.getHardwareArchitecture(), is(HardwareArchitecture.ARMHF));
        assertThat(nativeTarget.getAbi(), is(nullValue()));

        nativeTarget = ProvisioningHelper.detectFromText("bellsoft-jre21.0.2+14-linux-amd64.tar.gz");
        assertThat(nativeTarget.getOperatingSystem(), is(OperatingSystem.LINUX));
        assertThat(nativeTarget.getHardwareArchitecture(), is(HardwareArchitecture.X64));
        assertThat(nativeTarget.getAbi(), is(nullValue()));

    }

}