HSS_SUPPORT ?= y
HSS_TARGET ?= aries-m100pfsevp
UBOOT_VERSION = 2021.04
linux_defconfig := defconfig
linux_dtb := $(riscv_dtbdir)/microchip/mpfs-tysom-m.dtb
its_file := $(confdir)/32-bit-fit-image.its
tftp_boot_scr ?= 32b-boot.scr