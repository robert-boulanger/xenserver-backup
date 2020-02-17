# On the fly backup of Xenserver VM's

## Steps: 

### First: Create a backup flag/field

For every VM, in XenCenter go to the VM, Properties and add a User defined Test Field and name it "tobackup".
If the VM should be included in backup enter a value true, otherwise something else.

### Second: Mount a backup directory 

In Xencenter add a new storage (maybe CIFS or NFS or any other) and mount it
After it is configured, copy out the UUID (to find within XenCenter in the properties of the new storage)
insert this UUID in all variables MOUNTPOINT in all scripts after /var/run/sr-mount/ and replace the one provided in this scripts

### Third: Find UUID of storage where VM are running in
In Xenserver fin the UUID of your local Storage or wherever the VM's are installed to and copy also this UUID
Replace in all scripts the RESTORE_UUID variable with this UUID

### Fourth: (optional) replace XSNAME variable
If you like change the XSName variable in all scripts
type ´echo $HOSTNAME´ if you have more Xenservers for example

### Fifth: deploy the scripts
Transfer all scripts to the /root directory (home of root user) of your xenserver

### Sixth: create a crontabentry for backup.sh
Create a crontab entry for root on your Xenserver (crontab -e) and enter a line like
```
10 20 * * * /root/backup.sh
```
which would run the backup every day at 20:10 o'clock

### Seventh: make all scripts runable

don't forget to change the modus for the files
```
chmod 755 *.sh
```

## How it works

### Backup

On the share you provided in step 2 the script will create a directory called NEW.
While the VM's are running, it creates a snapshot in case the user defined field tobackup is set to true.
then it copies the snapshot to the backup directory and names it like the backed up VM is named 

This happens for very VM

Inside Xenserver the SNAPSHOT with name SNAPSHOT-VMNAME-DATE will kept until next run of the backup script.

The next day, it moves the NEW directory to OLD (if there was already an old folder, this will be deleted first.

Then the procedure begins again. but inside the xenserver, the Snapshot from the day before will be replaced with a fresh one.

In case of the need to restore the snapshot from the da before, just revert to this snapshot inside Xencenter.
You can omit this behaviou in case you have not enough diskspace by replacing the line

```
xe vm-uninstall uuid=${SNAPUUID_YESTERDAY} force=true
```
with
```
xe vm-uninstall uuid=${SNAPUUID} force=true
```
In this case the last snapshot taken will *not* be kept inside xenserver

In case to restore others procede as follows:

### Restore

Edit the scripts restore_all_* with the names of your vm's

call 

```
./restore_all_new.sh
```

to restore all VM'S from the last day, or

```
./restore_all_old.sh
```

to restore the backups from the day before yesterday.

If you just want to restore a single VM type

```
./restore_one_new.sh VMNAME
```

or analog to above 

```
./restore_all_old.sh VMNAME
```

in all restore cases, the backups become restored with the name:

```
SNAPSHOT_VMNAME_DATE
```

You have to rename them in xencenter, and you have to start them manually, but 
all properties, including the mac-address are preserved.
It is up to your responsibility to take care, no two VM's with same MAC are running the same time.


have fun....
