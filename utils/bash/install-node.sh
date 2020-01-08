#!/bin/bash

echo "this script will install the latest stable(12.x) version of nodejs"
echo "the instalation is for an amazon linux vm"

yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_12.x | bash -

yum install -y nodejs

node -v
npm -v