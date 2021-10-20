# SecureServer
Script for install and post install redhate based server
<br>

## 1st Step

<br>

install packer on your main (works with windows or linux). Linux go to [packer](https://www.packer.io/downloads). Windowd run .\getNecessary.ps1

download redhat based os (for exemple rockylinux minimal  : https://rockylinux.org/download/).

Copy type.vars.json into vars.json and edit file with iso path and make sure this is the right checksum.


Linux : `packer build --only=virtualbox-iso --var-file="vars.json"  rocky/rocky8.json `
Windows : `.\packer.exe build -only=vmwareiso -var-file="var.json" rocky/rocky8.json`

(you can change virtualbox by vmware)

Now your vm is building up, default ssh user is vagrant and password V@grant1

<br>

## 2nd Step
<br>

import the post installation script on your vm and run it.

`scp /home/yonix_nexro/SecureServer/post_install_script_rockylinux.sh root@192.168.0.1:/root/`

make it executable `chmod +x script` and then run it `./post_installation_script.sh`
