MOUNTPOINT=/var/run/sr-mount/102010de-9b9f-3ac2-f50c-4722977d10a1
XSNAME=xenserver
BACKUPPATH=${MOUNTPOINT}/${XSNAME}/OLD
RESTORE_UUID=c36091e7-4ec6-6860-2188-90ed41c4aa9a 
xe vm-import  filename="$BACKUPPATH/$1.xva" sr-uuid=$RESTORE_UUID  preserve=true