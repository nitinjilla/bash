#!/bin/bash

#Author: Nitin Jilla

#About: Helps install open-source git module

if ! [ $# -eq 1 ]; then

        echo "ERROR: Package version not defined. Exiting..."
        echo "Usage: git-install.sh <version>"
        echo "Example: git-install.sh 2.9.4"
        exit 1

else

        echo "Resolving package dependencies..."
        yum install -y autoconf cpio curl-devel expat-devel gcc gettext-devel make openssl-devel perl-ExtUtils-MakeMaker zlib-devel > /dev/null
        echo "Package dependencies resolved."

        echo "Installing git. This may take some time..."
        mkdir /temp-git && cd /temp-git
        wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-$1.tar.gz

        tar -xzvf git-$1.tar.gz
        cd git-$1

        make configure > /dev/null
        sh configure --prefix=/usr/local/git/ > /dev/null
        make && make install > /dev/null
        yum -y remove git > /dev/null                                           #Installing gettext-devel also installed git module from yum
        ln -sf /usr/local/git/bin/* /bin/

        #Delete tarball
        cd ..
        rm -rf /temp-git/git-$1.tar.gz

fi

echo "Git version $(git --version | awk '{print $3}') installed successfully!"
