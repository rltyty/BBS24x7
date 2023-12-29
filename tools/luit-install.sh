#/bin/sh
apt install -y make g++
cd /tmp
mkdir luit
wget https://invisible-island.net/datafiles/release/luit.tar.gz
tar xzvf luit.tar.gz -C ./luit --strip-components=1
cd luit
./configure
make

# vim: tw=78:ts=8:sts=4:sw=4:noet:ft=sh:norl:
