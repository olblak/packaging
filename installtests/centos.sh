#!/bin/bash
set -x  # Exit on any command failure or unset variables, can't use -u because of line 6

. "$(dirname $0)/sh2ju.sh"

if [ -z "$1" ]; then
  PKG_FOLDER=$(ls /tmp/packaging/target/rpm/*.rpm)
else 
  PKG_FOLDER="$1"
fi

dockerInstall() {
    # Assume packaging is mounted to /tmp/packaging and built
    yum install -y curl
    yum install -y system-config-services java-1.8.0-openjdk  # First is b/c docker does not include service command, second is prereq
    yum -y --nogpgcheck localinstall "$PKG_FOLDER"
}

juLog -name=centosDockerInstall dockerInstall
