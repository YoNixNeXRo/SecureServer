# SecureServer
Script for install and post install redhate based server, not finish yet
<br>

## 1st Step

<br>

install packer on your main (works with windows or linux). Linux go to [packer](https://www.packer.io/downloads). Windowd run .\getNecessary.ps1

download redhat based os (for exemple rockylinux minimal  : https://rockylinux.org/download/).

Edit vars.json with iso path and make sure this is the right checksum. (as you can see you can have multiple iso and it works with windows and linux), you can also edit rocky8.json to modify disk size.


Linux : `packer build --only=virtualbox-iso --var-file="vars.json"  rocky/rocky8.json `

Windows : `.\packer.exe build -only=vmwareiso -var-file="var.json" rocky/rocky8.json`

(change virtualizer with the one you have)

Now your vm is building up.

When its done the vm will delete itself and you can now import the .ovf machine file. In your virtualizer : import /path/to/SecureServer/output-virtualizer/Rocky8.ovf

default ssh user is vagrant and password V@grant1

> Big thanks to my friend AmaelFr for this part as it is not mine https://github.com/amaelFr/packer_template 

<br>

## 2nd Step
<br>

import the post installation script on your vm and run it.

`scp /home/yonix_nexro/SecureServer/post_install_script_rockylinux.sh root@192.168.0.1:/root/`

make it executable `chmod +x script` and then run it `./post_installation_script.sh`

tips before running it : 
- line 211 put your ssh key it you want to ssh as root. Please only consider using ed25519 key.
- to have an idea of your server security run `lynis audit system` score should never be under 80. This script objectif is between 85 and 90. Now its currently 80.
