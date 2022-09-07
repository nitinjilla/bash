### Creating users using Bash

#!/bin/bash

echo Validating if user $1 exists...

if [ $# -lt 1 ]; then
        echo 'Usage: sh createusers.sh <username>'

elif getent passwd $1 > /dev/null 2>&1; then
         echo "User $1 already exists."

else
         echo Creating user $1...
         read -s -p "Enter a password for $1: "  password
         sudo useradd -m $1
         echo $password | sudo passwd --stdin $1
         echo User $1 is created.
fi
