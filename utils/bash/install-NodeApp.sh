#!/bin/bash

yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_12.x | bash -

yum install -y nodejs

node -v
npm -v

npm install pm2@latest -g

if [ "$1" == "" ]; then
  echo 'please enter the url of the artifact repository'
fi
cd /opt/ || exit
curl -s -O "$1"

for a in *.tar.gz; do
  a_dir=$(expr "$a" : '\(.*\).tar.gz')
  mkdir -p "$a_dir"
  tar -xvzf "$a" -C "$a_dir"
  rm "$a"
done

cd "$a_dir" || exit

npm ci --production

pm2 start server.js
pm2 startup
pm2 save
