HSS_SUPPORT ?= y
UBOOT_VERSION = 2021.04
linux_defconfig := nezha_defconfig
linux_dtb := $(riscv_dtbdir)/allwinner/sun20i-d1-nezha.dtb
its_file := $(confdir)/d1-fit-image.its
tftp_boot_scr := d1-boot.scr