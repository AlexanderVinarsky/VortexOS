qemu-system-i386 -fda build/main_floppy.img 2>&1 | grep -viE "warning|note"
