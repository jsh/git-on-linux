#!/bin/bash -eu
# Create a default, Debian 10 (Buster) image in GCE
# and run this script.

set -o pipefail
trap 'ls /tmp/*.OUT; echo FAIL' ERR

PS4='[\t] '; set -x

# Get all the prerequisites
sudo apt update &> /tmp/apt-update.OUT &&
        wait
echo 'y' | sudo apt full-upgrade &> /tmp/apt-upgrade.OUT
	wait
for package in git make gcc libssl-dev zlib1g-dev libcurl4-openssl-dev libexpat1-dev gettext; do
	sudo apt install -y $package
	wait
done &>/tmp/apt-install.OUT
echo == setup complete

# Get the source
git clone -q https://github.com/git/git.git
echo == clone complete

# Build it
cd git
upstream_release=$(git tag -l v2.2[0-9].[0-9] | tail -1)
git checkout -q $upstream_release
make --quiet &> /tmp/make.OUT
echo == build complete

# Test it
cd t
prove -Q --timer --jobs 15 ./t[0-9]*.sh &> /tmp/prove.OUT
cd ..
echo == test complete

# Install it
make --quiet install &> /tmp/install.OUT
echo == install complete

echo SUCCESS
exit 0
