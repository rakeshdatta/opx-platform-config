#!/bin/bash

# Copyright (c) 2018 Dell Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# THIS CODE IS PROVIDED ON AN  *AS IS* BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT
# LIMITATION ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS
# FOR A PARTICULAR PURPOSE, MERCHANTABLITY OR NON-INFRINGEMENT.
#
# See the Apache Version 2.0 License for specific language governing
# permissions and limitations under the License.
#

. /etc/opx/opx-environment.sh

/usr/bin/pcisysfs.py --set --val 0x00000005 --offset 0x300 --res "/sys/devices/pci0000:00/0000:00:13.1/resource0"
#SM Bus HCLK divider register set 0x59 to tune 90khz frequency
/usr/bin/portiocfg.py --set --offset 0x402 --val 0x59
/usr/bin/portiocfg.py --set --offset 0x403 --val 0x0

# Put firmware verions of PLDs in a file
FIRMWARE_VERSION_FILE=/var/log/firmware_versions
rm -rf ${FIRMWARE_VERSION_FILE}
echo "BIOS: `dmidecode -s system-version `" > $FIRMWARE_VERSION_FILE
for f in /sys/bus/i2c/devices/*; do
    if [ "`cat $f/name`" = 'SMBus SCH adapter at 0400' ]; then
	b=`basename $f | sed 's/i2c-//'`
	# Get System CPLD version
	echo "System CPLD: $((`i2cget -y $b 0x31 0` & 0xf))" >> $FIRMWARE_VERSION_FILE
	# Get Master CPLD version
	echo "Master CPLD: $((`i2cget -y $b 0x32 1` & 0xf))" >> $FIRMWARE_VERSION_FILE
	# Get Slave CPLD version
	echo "Slave CPLD: $((`i2cget -y $b 0x33 0xa` & 0xf))" >> $FIRMWARE_VERSION_FILE
	break
    fi
done
