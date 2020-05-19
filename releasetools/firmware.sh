#!/sbin/sh

set -e

# Get the Yukon variant
deviceid=`getprop ro.build.product`

# Mount /system
mount -t ext4 /dev/block/platform/msm_sdcc.1/by-name/system /system

if [ $deviceid == "tianchi" ] || [ $deviceid == "flamingo" ]; then
    # Detect the exact model from the LTALabel partition
    # This looks something like:
    # 1291-1739_5-elabel-d2203-row.html
    mkdir -p /lta-label
    mount -r -t ext4 /dev/block/platform/msm_sdcc.1/by-name/LTALabel /lta-label
    variant=`ls /lta-label/*.html | sed s/.*-elabel-// | sed s/-row.html// | tr -d '\n\r'`
    umount /lta-label

    # Symlink the correct modem blobs
    basedir="/system/blobs/$variant/"
    cd $basedir
    find . -type f | while read file; do ln -s $basedir$file /system/etc/firmware/$file ; done
fi;

if [ $deviceid == "seagull" ]; then
    # Mount /firmware
    mount -t vfat /dev/block/platform/msm_sdcc.1/by-name/modem /firmware
    # Symlink the modem blobs from /firmware
    basedir="/firmware"
    cd $basedir
    find . -type f | while read file; do ln -sf $basedir$file /system/etc/firmware/$file ; done
fi;

exit 0
