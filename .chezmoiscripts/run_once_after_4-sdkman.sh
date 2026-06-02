#!/bin/bash

set -euo pipefail

echo "Installing SDKMAN..."

export SDKMAN_DIR="${HOME}/.sdkman"

if [ -d "$SDKMAN_DIR" ]; then
    echo "SDKMAN already installed. Skipping."
    exit 0
fi

curl -s "https://get.sdkman.io?rcupdate=false" | bash

source "${SDKMAN_DIR}/bin/sdkman-init.sh"

echo "Installing Java and Kotlin via SDKMAN..."
sdk install java 21.0.7-tem
sdk install kotlin 2.1.21

echo "SDKMAN installation completed."
