try {
    # We need java to function
    if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
        Write-Error "Dependency 'java' is missing. Please install it and ensure it's in your PATH, then re-run this script."
        exit 1
    }

    # In PowerShell, curl is an alias for Invoke-WebRequest. We check for the full command.
    if (-not (Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue)) {
        Write-Error "The 'Invoke-WebRequest' cmdlet is missing. This script requires at least PowerShell 3.0."
        exit 1
    }

    # Setup Temporary Directory and Paths
    $tempDir = $env:TEMP
    $helpersDir = Join-Path -Path $tempDir -ChildPath "provisioning-helpers"

    # Create the directory. -Force suppresses errors if it already exists.
    New-Item -Path $helpersDir -ItemType Directory -Force | Out-Null

    Write-Host "Created temporary directory at '$helpersDir'"

    # 3. Download Files
    # Define files to download in a structured way
    $filesToDownload = @(
        @{
            Uri  = "https://cdn.fizzed.com/provisioning/helpers/blaze.jar"
            OutFile = "blaze.jar"
        },
        @{
            Uri  = "https://cdn.fizzed.com/provisioning/helpers/blaze.conf"
            OutFile = "blaze.conf"
        },
        @{
            Uri  = "https://cdn.fizzed.com/provisioning/helpers/blaze.java"
            OutFile = "blaze.java"
        }
    )

    Write-Host "Downloading helper files..."

    # Loop through and download each file
    foreach ($file in $filesToDownload) {
        $destinationPath = Join-Path -Path $helpersDir -ChildPath $file.OutFile
        # The -UseBasicParsing switch is good for compatibility. The original used --insecure,
        # which isn't typically needed for GitHub, but could be added with -SkipCertificateCheck in PS Core.
        Invoke-WebRequest -Uri $file.Uri -OutFile $destinationPath -UseBasicParsing
        Write-Host " -> Downloaded $($file.OutFile)"
    }

    # Execute the Java Application
    Write-Host "Executing blaze installer..."

    $jarPath = Join-Path -Path $helpersDir -ChildPath "blaze.jar"
    $javaPath = Join-Path -Path $helpersDir -ChildPath "blaze.java"

    # The automatic variable '$args' in PowerShell contains all arguments passed to the script,
    # just like '$@' in the shell script.
    java -jar $jarPath $javaPath install_java_path $args

}
finally {
    # cleanup helpers directory
    if (Test-Path -Path $helpersDir) {
        Write-Host "Cleaning up temporary directory..."
        Remove-Item -Path $helpersDir -Recurse -Force
    }
}