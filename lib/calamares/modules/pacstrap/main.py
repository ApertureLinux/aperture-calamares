#!/usr/bin/env python3

import subprocess
import libcalamares

def run():
    try:
        root_mount_point = libcalamares.globalstorage.value("rootMountPoint")
        with open('/tmp/chrootpath.txt', 'w') as file:
            file.write(root_mount_point)
            file.close()
    except:
        pass

    subprocess.call([
        "/usr/lib/calamares/modules/pacstrap/base_install.sh"
    ])
