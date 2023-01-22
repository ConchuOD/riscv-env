OSBI_SUPPORT ?= y
SPL_SUPPORT ?= y
UBOOT_VERSION = 30238f666d2736063f615613b7297efde20c3d49
linux_defconfig := $(confdir)/$(DEVKIT)/defconfig
linux_dtb := $(riscv_dtbdir)/starfive/jh7110-starfive-visionfive-2-va.dtb
buildroot_initramfs_config := $(confdir)/$(DEVKIT)/buildroot_initramfs_config
its_file := $(confdir)/32-bit-fit-image.its
tftp_boot_scr := vision5v2-boot.scr