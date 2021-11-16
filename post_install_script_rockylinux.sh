#!/bin/bash

# Name        :   YoNix_NeXRo
#
# Version     :   v3
# Changelog   : more security features
# State       : still on going
# Lynis score : 83

requirements(){

    #sentenforce 0
    sed -i 's/enforcing/disabled/g' /etc/selinux/config
    systemctl stop firewalld
    systemctl disable firewalld 
}

update_install_remove(){
    yum update -y
    yum remove -y iwl* bluez* telnet
    yum install epel-release -y
    yum config-manager --set-enabled powertools
    yum install vim mlocate tmux zip dstat iotop git psmisc tree mc curl  openssl lynis pigz glibc-all-langpacks rsync htop glances net-tools bash-completion lynx figlet rkhunter -y
    localectl set-locale LANG=fr_FR.utf8
    localectl set-keymap fr
    localectl set-x11-keymap fr

}

setup_bashrc(){

    cat >> /tmp/.bashrc << EOF
    HISTOCONTROL=ignoreboth
    HISTSIZE=100000
    HISTFILESIZE=100000
    export PROMPT_COMMAND='history -a;history -n;history -w'
    export PS1='\n\e[0;31m\[******************************\n[\t] \u@\h \w \$ \e[m'
    alias ll='ls -lh'
    alias la='ls -lha'
    alias l='ls -CF'
    alias em='emacs -nw'
    alias dd='dd status=progress'
    alias _='sudo'
    alias _i='sudo -i'
    alias please='sudo'
    alias fucking='sudo'
    alias df="df -hT --total -x devtmpfs -x tmpfs"
    alias rm="rm -iv --preserve-root"
    alias grep="grep --color=auto"
    alias vi="vim"
    alias ll="ls -l"
    alias cp="cp -i"                          # confirm before overwriting something
    alias free='free -m'                      # show sizes in MB
    alias more='less'
    alias chmod="chmod -v --preserve-root"
    alias reboot="shutdown -r"
    alias off="shutdown -h"
    alias grep="grep --color"
    alias more="less"
    alias chown="chown -v --preserve-root"
    alias chgrp="chgrp -v --preserve-root"
    alias plantu="netstat -plantu"
    alias lz="ll -z"
    alias pz="ps -faxZ"
    alias plantuZ="plantu -Z"

EOF


    mv /root/.bashrc /root/.bashrc_old
    cp /tmp/.bashrc /root/.bashrc
    chmod 770 /root/.bashrc

    user=$(grep bash /etc/passwd|tail -1| cut -d: -f1)


    mv /home/$user/.bashrc /home/$user/.bashrc_old
    cp /tmp/.bashrc /home/$user/.bashrc
    chown $user /home/$user/.bashrc
    chmod 770 /home/$user/.bashrc
    cat >> /home/$user/.bashrc << EOF
    export PS1="\[\e[32m\][\[\e[m\]\[\e[31m\]\u\[\e[m\]\[\e[33m\]@\[\e[m\]\[\e[32m\]\h\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[32m\]]\[\e[m\]\[\e[32;47m\]\\$\[\e[m\] "
EOF
}

setup_issue(){

    cat > /etc/issue.net << EOF
    *********************************************************************************
    *                                                                               *
    *   NOTICE TO USERS                                                             *
    *                                                                               *
    *   This computer system is the private property of its owner, whether          *
    *   individual, corporate or government.  It is for authorized use only.        *
    *   Users (authorized or unauthorized) have no explicit or implicit             *
    *   expectation of privacy.                                                     *
    *                                                                               *
    *   Any or all uses of this system and all files on this system may be          *
    *   intercepted, monitored, recorded, copied, audited, inspected, and           *
    *   disclosed to your employer, to authorized site, government, and law         *
    *   enforcement personnel, as well as authorized officials of government        *
    *   agencies, both domestic and foreign.                                        *
    *                                                                               *
    *   By using this system, the user consents to such interception, monitoring,   *
    *   recording, copying, auditing, inspection, and disclosure at the             *
    *   discretion of such personnel or officials.  Unauthorized or improper use    *
    *   of this system may result in civil and criminal penalties and               *
    *   administrative or disciplinary action, as appropriate. By continuing to     *
    *   use this system you indicate your awareness of and consent to these terms   *
    *   and conditions of use. LOG OFF IMMEDIATELY if you do not agree to the       *
    *   conditions stated in this warning.                                          *
    *                                                                               *
    *********************************************************************************
EOF

    cp /etc/issue.net /etc/motd
    figlet READ_ABOVE_STATEMENT >>/etc/motd
    \cp /etc/issue.net /etc/issue

}

password_expiration(){
    sed -i '/PASS_MAX_DAYS/s/99999/180/' /etc/login.defs
    sed -i '/PASS_MIN_LEN/s/5/12/' /etc/login.defs
    sed -i '/PASS_WARN_AGE/s/7/12/' /etc/login.defs
    sed -i '/PASS_MIN_DAYS/s/0/1/' /etc/login.defs
    sed -i '/UMASK/s/022/0077/' /etc/login.defs
    sed -i '/umask/s/002/0077/' /etc/profile
    sed -i '/umask/s/022/0077/' /etc/profile
    
    cat >> /etc/login.defs << EOF
#change encrypt method
SHA_CRYPT_MIN_ROUNDS 99999

FAIL_DELAY 5

FAILLOG_ENAB yes

LOG_OK_LOGINS yes

LOG_UNKFAIL_ENAB yes

LOGIN_RETRIES 3

PASS_ALWAYS_WARN yes

OBSCURE_CHECKS_ENAB yes

EOF
}

grub_modification(){

    cat >> /etc/default/grub << EOF
GRUB_DISABLE_RECOVERY="true"
GRUB_DISABLE_SUBMENU="true"
EOF


    #############################
    #                           #
    #   grub setup timeout      #
    #                           #
    #############################
    sed -i 's/=5/=30/' /etc/default/grub


    #############################
    #                           #
    #   grub  video quality     #
    #                           #
    #############################

    sed -i 's/quiet/vga=791/' /etc/default/grub
    sed -i "/GRUB_GFXMODE/s/^#//" /etc/default/grub
    sed -i "/GRUB_GFXMODE/s/640x480/1920x1080/" /etc/default/grub

    #############################
    #                           #
    #   grub setup password     #
    #                           #
    #############################


    sed -i '$a set superusers="grub"' /etc/grub.d/40_custom
    grub_mdp_hash=`echo -e "grub\ngrub" | grub-mkpasswd-pbkdf2 | grep grub | awk -F " " '{ print $7}'`

    sed -i '$a password_pbkdf2 grub HASH' /etc/grub.d/40_custom
    sed -i "/HASH/s/HASH/$grub_mdp_hash/" /etc/grub.d/40_custom


    sed -i 's/--class os/--class os --unrestricted/g' /etc/grub.d/10_linux

    grub2-mkconfig -o "$(readlink -e /etc/grub2.cfg)"

}

ssh_key_creation(){
    #############################
    #                           #
    #   creat ssh key for root  #
    #                           #
    #############################


    mkdir -v ~/.ssh
    chmod -v 700 ~/.ssh

    ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -q -N ""
    cat id_ed25519.pub >> /root/.ssh/authorized_keys
    echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqyToSio/QdJELe8irhi1Yy9zBC4LVSWJr3OQRYIYLf root@MXLINUX >> /root/.ssh/authorized_keys

    #############################
    #                           #
    #   creat ssh key for user  #
    #                           #
    #############################


    mkdir -v /home/$user/.ssh
    chmod -v 700 /home/$user/.ssh
    ssh-keygen -t ed25519 -f /home/$user/.ssh/id_ed25519 -q -N ""
    chmod -v 700 /home/$user

    #test
    chown -R $user:$user /home/$user/.ssh

}

fstab_modification(){
    
    
    lv=`ls /dev/mapper | grep VG`
    cp -vip /etc/fstab /etc/fstab.bak 
    for i in $lv; do 
        uid=`blkid /dev/mapper/$i -s UUID -o value`
        sed -ie "s/\/dev\/mapper\/$i/UUID=$uid/g" /etc/fstab
    done

}

last_ssh_login(){

        cat >> /etc/profile << EOF
    last | head -n 5
EOF
}

disable_usb(){
    cat >> /etc/modprobe.conf << EOF
install usb-storage : 
install tipc /bin/true
install rds /bin/true
install sctp /bin/true
install dccp /bin/true
install firewire-core /bin/true
EOF

    echo 'install usb-storage /bin/true' >> disable-usb-storage.conf
    modprobe -r usb-storage
    mv -v /lib/modules/$(uname -r)/kernel/drivers/usb/storage/usb-storage.ko* /root

    cat >> /etc/modprobe.d/blacklist.conf << EOF
blacklist usb-storage
blacklist tipc
blacklist rds
blacklist sctp
blacklist dccp
blacklist firewire-core
EOF

}

ssh_configuration_hardening(){
    
    #sed -i 's/PASS_MIN_LEN[[:blank:]]5/PASS_MIN_LEN 12/g' /etc/login.defs
    sed -i 's/#AllowTcpForwarding[[:blank:]]yes/AllowTcpForwarding NO/g' /etc/ssh/sshd_config
    sed -i 's/#ClientAliveCountMax[[:blank:]]3/ClientAliveCountMax 2/g' /etc/ssh/sshd_config
    sed -i 's/#Compression[[:blank:]]delayed/Compression NO/g' /etc/ssh/sshd_config
    sed -i 's/#LogLevel[[:blank:]]INFO/LogLevel VERBOSE/g' /etc/ssh/sshd_config
    sed -i 's/#MaxAuthTries[[:blank:]]6/MaxAuthTries 3/g' /etc/ssh/sshd_config
    sed -i 's/#MaxSessions[[:blank:]]10/MaxSessions 2/g' /etc/ssh/sshd_config
    sed -i '/PermitRootLogin/s/yes/without-password/' /etc/ssh/sshd_config
    sed -i '/X11Forwarding/s/yes/NO/' /etc/ssh/sshd_config
    sed -i 's/#AllowAgentForwarding[[:blank:]]yes/AllowAgentForwarding NO/g' /etc/ssh/sshd_config
    sed -i 's/#TCPKeepAlive[[:blank:]]yes/TCPKeepAlive NO/g' /etc/ssh/sshd_config
    sed -i 's/#Port[[:blank:]]22/Port 2222/' /etc/ssh/sshd_config
    sed -i 's/#UseDNS[[:blank:]]yes/UseDNS NO/' /etc/ssh/sshd_config
    
    
    cat >> /etc/security/limits.conf << EOF
* hard core 0
* soft core 0
EOF
	
	cat >> /etc/sysctl.d/9999-disable-core-dump.conf << EOF
fs.suid_dumpable=0
kernel.core_pattern=|/bin/false
EOF

	sysctl -p /etc/sysctl.d/9999-disable-core-dump.conf
    
    sysctl -a > /tmp/sysctl-defaults.conf
    
    cat >> /etc/sysctl.d/80-lynis.conf << EOF
kernel.kptr_restrict = 2
kernel.sysrq = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.log_martians = 1
#net.ipv4.tcp_timestamps = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0    
EOF
sysctl --system
rkunter --update
rkhunter --propupd
    
}
clean_hostname(){
    hostname="MY.HOSTNAME"
    domain=".me.local"
    echo "$hostname$domain" > /etc/hostname
    ip=`ip -o -4 addr list | grep 2: | awk '{print $4}' | cut -d/ -f1`
    echo "$ip    $hostname    $hostname$domain"
    
    echo "$ip   $hostname" >> /etc/hosts
}

change_time(){

timedatectl set-ntp off
#set good time zonel
timedatectl set-timezone Europe/Paris
#NTP
timedatectl set-ntp on 
}

set_static_ip(){
    ip=`hostname -I`
    gw=`ip r | grep default | awk '{ print $3}'`
    it=`ip a | grep "state UP" | awk -F ": " '{ print $2 }'`

    cat > /etc/sysconfig/network-scripts/ifcfg-$it << EOF
DEVICE=$it
ONBOOT=yes
IPADDR=$ip
PREFIX=24
GATEWAY=$gw
DNS1=1.1.1.1
DNS2=8.8.8.8
IPV6_PRIVACY=no
EOF


}


main(){

    requirements
    update_install_remove
    setup_bashrc
    setup_issue
    password_expiration
    grub_modification
    ssh_key_creation
    ssh_configuration_hardening
    fstab_modification
    last_ssh_login
    disable_usb
    clean_hostname
    change_time
    set_static_ip
    updatedb
    reboot
}

main


