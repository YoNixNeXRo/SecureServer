$CACHEDIR="./cache"

'vmware','virtualbox' | % {mkdir -Force "$CACHEDIR\$_" }

# $VMWARETOOLSLINK="https://packages.vmware.com/tools/esx/latest/windows/"
# $VMWAREISO=( (curl $VMWARETOOLSLINK).Links.href | Select-String -Pattern .*\.iso$ ) -replace '^\r\n$', ''
# curl ${VMWARETOOLSLINK}${VMWAREISO} -o $CACHEDIR/vmware/vmware-tools.iso


# $VIRTUALBOXTOOLSLINK="http://download.virtualbox.org/virtualbox"
# $VIRTUALBOXVERSION=((curl $VIRTUALBOXTOOLSLINK/LATEST-STABLE.TXT).Content)  -replace '\n$'
# $VIRTUALBOXISO=((curl ($VIRTUALBOXTOOLSLINK+"/"+$VIRTUALBOXVERSION)).Links.href | Select-String -Pattern .*\.iso$ ) -replace '^\r\n$', ''
# curl ($VIRTUALBOXTOOLSLINK+"/"+$VIRTUALBOXVERSION+"/"+$VIRTUALBOXISO) -o $CACHEDIR/virtualbox/virtualbox-tools.iso

# Download last packer version

$basePackerURL="https://releases.hashicorp.com"
$linkObj=$(curl "${basePackerURL}/packer/").Links[1]
curl "${basePackerURL}$($linkObj.href)$($linkObj.innerText)_windows_amd64.zip" -o "packer.zip"

Expand-Archive ".\packer.zip" -DestinationPath "packer.tmp"
mv ".\packer.tmp\packer.exe" ".\packer.exe"

rm -Force .\packer.zip
rm -Force .\packer.tmp
