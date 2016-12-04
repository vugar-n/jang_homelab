#!/bin/sh

# reconfigure grub.conf (able to boot windows after adding ntfs-3g package)
grub2-mkconfig -o /boot/grub2/grub.conf

# rebuilt initial RAM disk (for LVM TRIM)
dracut --regenerate-all --force

