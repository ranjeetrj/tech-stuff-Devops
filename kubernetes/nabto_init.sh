#!/bin/bash

# UNABTO TUNNEL

rm -rf unabto

sudo apt-get update

sudo apt-get install git cmake

mkdir git

cd git

git clone https://github.com/nabto/unabto.git

cd unabto/apps/tunnel

mkdir build

cd build

cmake -DCMAKE_BUILD_TYPE=Release ..

make -j

sudo cp ./unabto_tunnel /bin

# LIB_PAM

sudo apt-get install libpam-cracklib -y

sudo cp /etc/pam.d/common-password /tmp

sudo cp -rvf common-password /etc/pam.d/

