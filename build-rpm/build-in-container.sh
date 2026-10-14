#!/bin/bash
set -euxo pipefail
dnf install -y dnf-plugins-core rpm-build git
git config --global user.email "rpmbuild@localhost"
git config --global user.name "rpmbuild"
cd /root
curl -fsSLO "https://download.copr.fedorainfracloud.org/results/@virtmaint-sig/virt-preview/fedora-44-x86_64/00994381-qemu/qemu-11.1.2-2.fc44.src.rpm"
rpm -Uvh qemu-11.1.2-2.fc44.src.rpm
cd /root/rpmbuild
cp /in/0003-qemu-vhost-user-fetch-config-in-chunks.patch SOURCES/
cd SPECS
n=$(grep -n '^Patch:' qemu.spec | tail -1 | cut -d: -f1)
sed -i "${n}a Patch: 0003-qemu-vhost-user-fetch-config-in-chunks.patch" qemu.spec
sed -i 's/^Release: %autorelease.*/Release: 99%{?dist}/' qemu.spec
grep '^Release:' qemu.spec
dnf builddep -y qemu.spec
rpmbuild -bb --nocheck --define 'dist .fc44.falcos1' qemu.spec
mkdir -p /out
find /root/rpmbuild/RPMS -name '*.rpm' -exec cp {} /out/ \;
ls -la /out | tail -30
