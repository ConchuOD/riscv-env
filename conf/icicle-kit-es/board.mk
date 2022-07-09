HSS_SUPPORT ?= y
HSS_TARGET ?= mpfs-icicle-kit-es
UBOOT_VERSION = 2022.01
linux_defconfig := mpfs_defconfig
buildroot_defconfig := $(confdir)/buildroot_initramfs_config
linux_dtb := $(riscv_dtbdir)/microchip/mpfs-icicle-kit.dtb
its_file := $(confdir)/64-bit-fit-image.its
