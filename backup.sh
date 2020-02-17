#!/bin/bash
#
# Written By: Mr Rahul Kumar
# Adopted By: Robert Boulanger
# Created date: Jun 14, 2014
# Last Updated: Mar 08, 2017
# Version: 1.2.1
# Visit: https://tecadmin.net/backup-running-virtual-machine-in-xenserver/
#

DATE=`date +%d%b%Y`
YESTERDAY=`date +%d%b%Y  --date="yesterday"`
XSNAME=xenserver
UUIDFILE=/root/xen-uuids.txt
MOUNTPOINT=/var/run/sr-mount/102010de-9b9f-3ac2-f50c-4722977d10a1



OLDBACKUPPATH=${MOUNTPOINT}/${XSNAME}/OLD
BACKUPPATH=${MOUNTPOINT}/${XSNAME}/NEW
rm -rf ${OLDBACKUPPATH}
mv ${BACKUPPATH} ${OLDBACKUPPATH}
mkdir -p ${BACKUPPATH}
#[ ! -d ${BACKUPPATH} ]  && echo "No backup directory found"; exit 0


# Fetching list UUIDs of all VMs running on XenServer
xe vm-list is-control-domain=false is-a-snapshot=false other-config:XenCenter.CustomFields.tobackup=yes | grep uuid | cut -d":" -f2 > ${UUIDFILE}

#[ ! -f ${UUIDFILE} ] && echo "No UUID list file found"; exit 0

while read VMUUID
do
    VMNAME=`xe vm-list uuid=$VMUUID | grep name-label | cut -d":" -f2 | sed 's/^ *//g'`
    echo "Starting with $VMNAME"
    SNAPUUID=`xe vm-snapshot uuid=$VMUUID new-name-label="SNAPSHOT-$VMNAME-$DATE"`
    SNAPNAME_YESTERDAY="SNAPSHOT-${VMNAME}-${YESTERDAY}"
    SNAPUUID_YESTERDAY=`xe snapshot-list name-label=${SNAPNAME_YESTERDAY} | grep uuid | cut -d":" -f2 | sed 's/^ *//g'`
    echo "New Snapshot is  SNAPSHOT-${VMNAME}-${DATE}"
    echo "Yesterday Snapshot is ${SNAPNAME_YESTERDAY} with uuid ${SNAPUUID_YESTERDAY}"
    echo "Created Snapshot SNAPSHOT-$VMNAME-$DATE"
    xe template-param-set is-a-template=false ha-always-run=false uuid=${SNAPUUID}

    xe vm-export vm=${SNAPUUID} filename="$BACKUPPATH/$VMNAME.xva"
    echo "export done to $BACKUPPATH/$VMNAME.xva"
    xe vm-uninstall uuid=${SNAPUUID_YESTERDAY} force=true
    echo "Snapshot deleted"
    echo " ----------------------------------------------------"
    echo " "
done < ${UUIDFILE}