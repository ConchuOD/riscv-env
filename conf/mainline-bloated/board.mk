HSS_SUPPORT ?= y
HSS_TARGET ?= mpfs-icicle-kit-es
UBOOT_VERSION = 2022.01
DEVKIT = polarberry
linux_defconfig := defconfig
buildroot_initramfs_config := $(confdir)/$(DEVKIT)/buildroot_initramfs_config
linux_dtb := $(riscv_dtbdir)/microchip/mpfs-polarberry.dtb
its_file := $(confdir)/32-bit-fit-image.its
