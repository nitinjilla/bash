#!/bin/bash

#Author: Nitin Jilla

#Using tar from https://mirrors.edge.kernel.org/pub/software/scm/git/ to upgrade Git on RHEL7

#Usage: upgrade-git.sh <version>
#Example upgrade-git.sh 2.9.4

mkdir /temp-git && cd /temp-git
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-$1.tar.gz

echo Resolving package dependencies...
yum install -y autoconf cpio curl-devel expat-devel gcc gettext-devel make openssl-devel perl-ExtUtils-MakeMaker zlib-devel > /dev/null
echo Package dependencies resolved.

tar -xzvf git-$1.tar.gz
cd git-$1

make configure
sh configure --prefix=/usr/local/git/
make && make install
yum -y remove git > /dev/null	     					#(installing gettext-devel also installed git module)
ln -sf /usr/local/git/bin/* /bin/

#Delete tarball
cd ..
rm -rf /root/git-$1.tar.gz

echo Git upgraded to version $(git --version | awk '{print $3}') successfully!
