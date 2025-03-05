# backup_and_process

Backup and process watch scripts which were designed for IneoUSA
before Centreon/Nagios was implemented for them 

Here's a breakdown of what each segment in the script does:

Shebang and Debug Mode

#!/bin/sh -x

#!/bin/sh specifies that the script should run using the Bourne shell (sh).
-x enables debugging, printing each command before executing it.


1. Function: usageQuit()

usageQuit()
{
  cat << "EOF" >&2
Usage $0 [-o output] [-i|-f] [-n]
  -o lets you specify an alternative backup file/device
  -i is an incremental or -f is a full backup, and -n prevents
  updating the timestamp if an incremental backup is done.
EOF
  exit 1
}
Displays usage instructions if incorrect options are passed.
Redirects the message to standard error (>&2).
Exits with status 1 (error).


2. Default Variables

compress="gzip"  # Compression method
inclist="/ineobackups/servers/ineoserv/backup.usr-local.inclist.$(date +%d%m%y)"
output="/ineobackups/servers/ineoserv/backup.usr-local.$(date +%d%m%y).tgz"
tsfile="/.backup.timestamp"  # Timestamp file for incremental backup
btype="incremental"  # Default to incremental backup
noinc=0  # Default: update the timestamp file after backup
Sets default values for compression (gzip).
Defines backup filenames with a date stamp.
Defaults to an incremental backup.


3. Trap to Clean Up Temporary Files

trap "/bin/rm -f $inclist" EXIT
Ensures that $inclist is removed when the script exits.


4. Parse Command-Line Options

while getopts "o:ifn" arg; do
  case "$arg" in
    o ) output="$OPTARG";       ;;  # Custom backup output location
    i ) btype="incremental";    ;;  # Incremental backup
    f ) btype="full";           ;;  # Full backup
    n ) noinc=1;                ;;  # Prevents updating timestamp
    ? ) usageQuit               ;;  # Invalid argument
  esac
done
shift $(( $OPTIND - 1 ))
Processes flags:
-o: Sets custom backup destination.
-i: Selects incremental backup.
-f: Selects full backup.
-n: Prevents timestamp update after incremental backup.
shift $(( $OPTIND - 1 )) removes processed options.


5. Display Selected Backup Type

echo "Doing $btype backup, saving output to $output"
Prints the backup type and destination.


6. Set Timestamp for Updates

timestamp="$(date +'%m%d%I%M')"
Generates a timestamp (MMDDHHMM format) for tracking backup time.


7. Perform Backup
Incremental Backup

if [ "$bytpe" = "incremental" ] ; then
Bug: Typo in bytpe, should be btype.

  if [ ! -f $tsfile ] ; then
    echo "Error: cant do an incremtnal backup: no timestamp file" >&2
    exit 1
  fi
Ensures the timestamp file exists; otherwise, it exits.

  find /usr/local -depth -type f -newer $tsfile | \
    pax -v -w -x ustar | $compress > $output
Finds files in /usr/local newer than $tsfile (i.e., modified since the last backup).
Archives them using pax in ustar format.
Compresses the archive with gzip.

  ls -al $output | mail -s "INCREMENTAL Backup of INEOSERV's /usr/local has completed" root
  failure="$?"
Lists the backup file and emails a completion notice.
Captures the success/failure status ($?).
Full Backup

else
  find /usr/local -depth -type f | \
    pax -v -w -x ustar | $compress > $output
Finds all files in /usr/local.
Archives and compresses them.

  ls -al $output | mail -s "FULL Backup of INEOSERV's /usr/local has completed" root
  failure="$?"
Sends a completion email.


8. Update Timestamp for Incremental Backups

if [ "$noinc" = "0" -a "$failure" = "0" ] ; then
  touch -t $timestamp $tsfile
fi
If -n was not specified and the backup was successful ($failure=0), updates the timestamp file.


9. Exit Script

exit 0
Exits normally.

Summary
Supports full and incremental backups.
Uses pax for archiving and gzip for compression.
Saves backups in /ineobackups/servers/ineoserv/.
Sends an email upon completion.
Uses timestamps to track incremental backups.
