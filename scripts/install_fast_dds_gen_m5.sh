#!/bin/bash

fast_dds_gen_version="2.4.0"

FAST_DDS_WORK_DIR=./dds_build

if ! grep -q "deb http://deb.debian.org/debian unstable main non-free contrib" /etc/apt/sources.list; then
    sudo bash -c 'echo "deb http://deb.debian.org/debian unstable main non-free contrib" >> /etc/apt/sources.list'
fi

if ! grep -q "Package: * \nPin: release a=stable\nPin-Priority: 900\n\nPackage: *\nPin: release a=unstable\nPin-Priority: 50" /etc/apt/preferences.d/99pin-unstable; then
    sudo bash -c 'echo -e "Package: * \nPin: release a=stable\nPin-Priority: 900\n\nPackage: *\nPin: release a=unstable\nPin-Priority: 50\n" >> /etc/apt/preferences.d/99pin-unstable'
fi

sudo apt update
sudo apt purge default-jre default-jdk -y --auto-remove
sudo apt install -y openjdk-11-jdk
sudo apt-mark hold openjdk-11-jdk

p11-kit list-modules

openssl engine pkcs11 -t

sudo rm -rf ${FAST_DDS_WORK_DIR}

mkdir ${FAST_DDS_WORK_DIR}

cd ${FAST_DDS_WORK_DIR}
WORKSPACE=$PWD
cd $WORKSPACE
# Java packages for FastDDS Generator and other similar tools
sudo mkdir -p /usr/share/man/man1

sudo rm -rf /opt/gradle/
sudo mkdir /opt/gradle
cd /opt/gradle
sudo wget https://services.gradle.org/distributions/gradle-7.6.3-bin.zip
sudo unzip gradle-7.6.3-bin.zip
sudo rm -f gradle-7.6.3-bin.zip

sed -i -e '/export PATH=$PATH:\/opt\/gradle\/gradle-7.6.3\/bin/d' ~/.bashrc
echo 'export PATH=$PATH:/opt/gradle/gradle-7.6.3/bin' >> ~/.bashrc

export GRADLE_HOME=/opt/gradle/gradle-7.6.3
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
sed -i -e '/export JAVA_HOME=/d' ~/.bashrc
echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")' >> ~/.bashrc

export PATH=$PATH:/opt/gradle/gradle-7.6.3/bin

# Install Fast-DDS-Gen
cd $WORKSPACE
sudo rm -rf /opt/fast-dds-gen
sudo mkdir -p /opt/fast-dds-gen
git clone --recursive -b v$fast_dds_gen_version https://github.com/eProsima/Fast-DDS-Gen.git fast-dds-gen \
    && cd fast-dds-gen \
    && gradle assemble \
    && sudo /opt/gradle/gradle-7.6.3/bin/gradle install --install_path=/opt/fast-dds-gen

sed -i -e '/export PATH=$PATH:\/opt\/fast-dds\/bin/d' ~/.bashrc
echo 'export PATH=$PATH:/opt/fast-dds/bin' >> ~/.bashrc

sed -i -e '/export PATH=$PATH:\/opt\/fast-dds-gen\/bin/d' ~/.bashrc
echo 'export PATH=$PATH:/opt/fast-dds-gen/bin' >> ~/.bashrc


if grep 'export LD_LIBRARY_PATH=/opt/fast-dds/lib:$LD_LIBRARY_PATH' ~/.bashrc >/dev/null; then
  echo "LD_LIBRARY_PATH libs are already added"
else
  echo 'export LD_LIBRARY_PATH=/opt/fast-dds/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
  source ~/.bashrc
fi
sudo ldconfig

sudo sed -i '/deb http:\/\/deb.debian.org\/debian unstable main non-free contrib/d' /etc/apt/sources.list
sudo rm -f /etc/apt/preferences.d/99pin-unstable
