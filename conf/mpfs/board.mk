FSBL_SUPPORT ?= y
OSBI_SUPPORT ?= y
UBOOT_VERSION = 2022.01
linux_defconfig := defconfig
buildroot_initramfs_config := $(confdir)/buildroot_initramfs_config
linux_dtb := $(riscv_dtbdir)/sifive/hifive-unleashed-a00.dtb
its_file := $(confdir)/32-bit-fit-image.its
tftp_boot_scr ?= mpfs-boot.scr
