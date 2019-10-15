#!/bin/bash -ex

: "${AGENT_WORKDIR:=/tmp}"

mkdir -p "$RPMDIR/"
mkdir -p "$RPM_WEBDIR/"

rsync -avz "$RPM" "$RPMDIR/"

# $$ Contains current pid
D="$AGENT_WORKDIR/$$"

mkdir -p "$D/RPMS/noarch"

"$BASE/bin/indexGenerator.py" \
  --distribution redhat \
  --binaryDir "$RPMDIR" \
  --targetDir "$RPM_WEBDIR"

cp "${GPG_PUBLIC_KEY}" "$D/${ORGANIZATION}.key"

"$BASE/bin/branding.py" "$D"

cp "$RPM" "$D/RPMS/noarch"

cat  > "$D/${ARTIFACTNAME}.repo" << EOF
[${ARTIFACTNAME}]
name=${PRODUCTNAME}${RELEASELINE}
baseurl=${RPM_URL}
gpgcheck=1
EOF

pushd "$D"
  rsync -avz --exclude RPMS . "$RPM_WEBDIR/"
popd

# generate index on the server
createrepo --update -o "$RPM_WEBDIR" "$RPMDIR/"

gpg \
  --batch \
  --pinentry-mode loopback \
  --no-use-agent \
  --no-default-keyring \
  --keyring "$GPG_KEYRING" \
  --secret-keyring="$GPG_SECRET_KEYRING" \
  --passphrase-file "$GPG_PASSPHRASE_FILE" \
  -a \
  --detach-sign \
  --yes \
  "$SUSE_WEBDIR/repodata/repomd.xml"

rm -rf $D
