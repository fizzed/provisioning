#!/bin/sh

# we need java to function
if ! [ -x "$(command -v java)" ]; then
  echo "Dependency 'java' is missing. Please install it first then re-run this script"
  exit 1
fi

# Create a function to handle cleanup of temp dir even if script fails
cleanup() {
  echo "Cleaning up temp dir $TEMP_DIR"
  # Remove the directory only if $TEMP_DIR is set and it's a directory
  if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}

# Set the trap. This catches any script exit (normal, error, or signal). The 'cleanup' function will run when the script exits.
trap cleanup EXIT

# --- Portable Download Function ---
#
# @description: Downloads a URL to a specific file, using the
#               first available tool: curl, wget, or fetch.
#
# @arg $1: The URL to download.
# @arg $2: The local file path to save to.
#
# @exitcode 0: Success.
# @exitcode 1: Failure (or if no download tool is found).
#
download_file() {
  URL="$1"
  OUTPUT_FILE="$2"

  # Check for curl
  if command -v curl >/dev/null 2>&1; then
    # -f: Fail fast with non-zero exit code on server errors (404, etc.)
    # -L: Follow redirects
    # -s: Silent mode
    # -o: Write to output file
    curl -f -L -s -o "$OUTPUT_FILE" "$URL"
    return $?

  # Check for wget
  elif command -v wget >/dev/null 2>&1; then
    # -q: Quiet mode
    # -O: Write to output file
    # (wget returns non-zero on 404s and other errors by default)
    wget -q -O "$OUTPUT_FILE" "$URL"
    return $?

  # Check for fetch (common on FreeBSD/OpenBSD)
  elif command -v fetch >/dev/null 2>&1; then
    # -q: Quiet mode
    # -o: Write to output file
    # (fetch returns non-zero on failure)
    # NOTE: 'fetch' does not follow redirects by default
    fetch -q -o "$OUTPUT_FILE" "$URL"
    return $?

  # Check for OpenBSD's ftp client
  elif command -v ftp >/dev/null 2>&1 && [ "$(uname)" = "OpenBSD" ]; then
    echo "Using OpenBSD ftp to download..."
    # -o: specifies the output file
    ftp -o "$OUTPUT_FILE" "$URL"
    return $?

  else
    echo "Error: No download tool (curl, wget, fetch, or ftp) found. Please install one of those and retry." >&2
    return 1
  fi
}

# Create the unique temporary directory
# mktemp -d creates a directory with a unique name
TEMP_DIR=$(mktemp -d /tmp/provisioning.XXXXXX)
echo "Created temp dir $TEMP_DIR"

echo "Downloading blaze.jar to temp dir..."
download_file "https://cdn.fizzed.com/provisioning/helpers/blaze.jar" "$TEMP_DIR/blaze.jar"
download_file "https://cdn.fizzed.com/provisioning/helpers/blaze.conf" "$TEMP_DIR/blaze.conf"
download_file "https://cdn.fizzed.com/provisioning/helpers/blaze.java" "$TEMP_DIR/blaze.java"

java "-Djava.io.tmpdir=$TEMP_DIR" -jar "$TEMP_DIR/blaze.jar" "$TEMP_DIR/blaze.java" install_maven "$@"

rm -Rf "$TEMP_DIR"