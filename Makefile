ISA ?= rv64imafdc

ABI ?= lp64d

LIBERO_PATH ?= /usr/local/microsemi/Libero_v2021.1/
SC_PATH ?= /usr/local/microsemi/SoftConsole-v2021.1/
fpgenprog := $(LIBERO_PATH)/bin64/fpgenprog
num_threads := $(shell nproc --ignore=1)
num_threads := $(shell echo $$(( $(num_threads) + 2 )))
# num_threads = 4

srcdir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
srcdir := $(srcdir:/=)
patchdir := $(CURDIR)/patches
confdir := $(srcdir)/conf
wrkdir := $(CURDIR)/work

LINUX_DIR ?= /stuff/linux
linux_srcdir := $(LINUX_DIR)
linux_wrkdir := $(wrkdir)/linux
riscv_dtbdir := $(linux_wrkdir)/arch/riscv/boot/dts/

# target icicle w/ emmc by default
DEVKIT ?= icicle-kit-es
ifeq "$(DEVKIT)" "icicle-kit-es-sd"
override DEVKIT = icicle-kit-es
endif

include conf/$(DEVKIT)/board.mk

export CCACHE_DIR := /stuff/ccache
export CCACHE_TEMPDIR := /stuff/ccache/tmp

GCC_VERSION ?= 13
LLVM_VERSION ?= 16
BINUTILS_VERSION ?= 2.35
TOOLCHAIN_DIR := /stuff/toolchains
LLVM_DIR ?= $(TOOLCHAIN_DIR)/llvm-$(LLVM_VERSION)
GCC_DIR ?= $(TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)
SPARSE_DIR ?= $(CURDIR)/sparse
BINUTILS_DIR ?= $(TOOLCHAIN_DIR)/binutils-$(BINUTILS_VERSION)
RUSTDIR ?= ~/.rustup/toolchains/1.62-x86_64-unknown-linux-gnu
QEMU_DIR ?= qemu/
XEN_DIR ?= xen/

qemu := $(QEMU_DIR)/build/qemu-system-riscv64
qemu_arm := $(QEMU_DIR)/arm_build/qemu-system-aarch64
qemu_dtb := work/qemu.dtb

xen_srcdir := $(XEN_DIR)
xen_wrkdir := $(wrkdir)/xen
xen := $(xen_wrkdir)/xen

PATH := $(SPARSE_DIR):/$(LLVM_DIR)/bin:$(GCC_DIR)/bin:$(PATH)
GITID := $(shell git describe --dirty --always)

tc_build_dir := $(srcdir)/tc-build
llvm_srcdir := $(srcdir)/llvm
llvm_wrkdir := $(wrkdir)/llvm
toolchain_srcdir := $(srcdir)/riscv-gnu-toolchain
toolchain_wrkdir := $(wrkdir)/riscv-gnu-toolchain
binutils_srcdir := $(srcdir)/binutils
binutils_wrkdir := $(wrkdir)/binutils
toolchain_dest := $(GCC_DIR)
target := riscv64-unknown-linux-gnu
CROSS_COMPILE := $(target)-
target_gdb := $(CROSS_COMPILE)gdb
CROSS_COMPILE_CC := $(GCC_DIR)/bin/$(CROSS_COMPILE)gcc
rust_sysroot := $(RUSTDIR)/lib/rustlib/src/rust/library

LINUX_IAS ?= "LLVM_IAS=$(CLANG)"
LINUX_CROSS ?= "$(CROSS_COMPILE)"

ifeq ($(CLANG),1)
LINUX_CC ?= "CC=ccache clang"
LINUX_LLVM ?= "LLVM=$(CLANG)"
else
LINUX_CC ?= "CC=ccache $(CROSS_COMPILE_CC)"
endif

buildroot_srcdir := $(srcdir)/buildroot
buildroot_initramfs_wrkdir := $(wrkdir)/$(DEVKIT)/buildroot_initramfs
buildroot_initramfs_sysroot := $(wrkdir)/$(DEVKIT)/buildroot_initramfs_sysroot

buildroot_initramfs_tar := $(buildroot_initramfs_wrkdir)/images/rootfs.tar
buildroot_initramfs_config ?= $(confdir)/buildroot_initramfs_config

buildroot_patchdir := $(patchdir)/buildroot/
buildroot_patches := $(shell ls $(buildroot_patchdir)/*.patch)

kernel-modules-stamp := $(wrkdir)/.modules_stamp
kernel-modules-install-stamp := $(wrkdir)/$(DEVKIT)/.modules_install_stamp
buildroot_initramfs_sysroot_stamp := $(wrkdir)/$(DEVKIT)/.buildroot_initramfs_sysroot

vmlinux := $(linux_wrkdir)/vmlinux
vmlinux_stripped := $(linux_wrkdir)/vmlinux-stripped
vmlinux_bin := $(wrkdir)/vmlinux.bin
vmlinux_relocs := $(linux_wrkdir)/vmlinux.relocs

kernel-modules-stamp := $(wrkdir)/.modules_stamp
kernel-modules-install-stamp := $(wrkdir)/.modules_install_stamp

flash_image := $(wrkdir)/$(DEVKIT)-$(GITID).gpt
vfat_image := $(wrkdir)/$(DEVKIT)-vfat.part
initramfs_uc := $(wrkdir)/$(DEVKIT)-initramfs.cpio
initramfs := $(wrkdir)/initramfs.cpio.gz
fit := $(wrkdir)/fitImage.fit
uimage := $(wrkdir)/uImage

device_tree_blob := $(wrkdir)/riscvpc.dtb

fsbl_srcdir := $(srcdir)/fsbl
fsbl_wrkdir := $(wrkdir)/fsbl
fsbl_wrkdir_stamp := $(wrkdir)/.fsbl_wrkdir
fsbl_patchdir := $(patchdir)/fsbl/
libversion := $(fsbl_wrkdir)/lib/version.c
fsbl := $(wrkdir)/fsbl.bin

uboot_s := $(buildroot_initramfs_wrkdir)/images/u-boot.bin
uboot_s_cfg := $(confdir)/$(DEVKIT)/smode_defconfig
uboot_s_txt := $(confdir)/$(DEVKIT)/uEnv_s-mode.txt
uboot_s_scr := $(buildroot_initramfs_wrkdir)/images/boot.scr

opensbi_srcdir := $(srcdir)/opensbi
opensbi_wrkdir := $(wrkdir)/opensbi
opensbi := $(wrkdir)/$(DEVKIT)/fw_payload.bin
opensbi_dyn := $(wrkdir)/$(DEVKIT)/fw_dynamic.bin
opensbi_dyn_build := $(opensbi_wrkdir)/platform/generic/firmware/fw_dynamic.bin
opensbi_build := $(opensbi_wrkdir)/platform/generic/firmware/fw_payload.bin
second_srcdir := $(srcdir)/2ndboot
secondboot := $(wrkdir)/.2ndboot

tpl_its := $(confdir)/$(DEVKIT)/u-boot.its
tpl_img := $(wrkdir)/$(DEVKIT)/$(DEVKIT)-tpl.img

uboot_spl := $(buildroot_initramfs_wrkdir)/images/u-boot-spl.bin

v5v2_spl_tool_srcdir := $(srcdir)/v5-tools/spl_tool
v5v2_spl_tool := $(v5v2_spl_tool_srcdir)/spl_tool
v5v2_spl_interim := $(buildroot_initramfs_wrkdir)/images/u-boot-spl.bin.normal.out
v5v2_spl := $(wrkdir)/$(DEVKIT)/u-boot-spl.bin.normal.out

openocd_srcdir := $(srcdir)/riscv-openocd
openocd_wrkdir := $(wrkdir)/riscv-openocd
openocd := $(openocd_wrkdir)/src/openocd

payload_generator_url := https://github.com/polarfire-soc/hart-software-services/releases/download/2021.11/hss-payload-generator.zip
payload_generator_tarball := $(srcdir)/br-dl-dir/payload_generator.zip
# hss_payload_generator := /stuff/junk/hss-payload-generator
hss_payload_generator := $(wrkdir)/hss-payload-generator
hss_srcdir := $(srcdir)/hart-software-services
hss_uboot_payload_bin := $(wrkdir)/payload.bin
payload_config := $(confdir)/$(DEVKIT)/config.yaml

amp_example := $(buildroot_initramfs_wrkdir)/images/mpfs-rpmsg-remote.elf
amp_example_srcdir := $(srcdir)/polarfire-soc-examples/polarfire-soc-amp-examples/mpfs-rpmsg-freertos
amp_example_wrkdir := $(wrkdir)/amp/mpfs-rpmsg-freertos

GENIMAGE_CFG=$(confdir)/genimage-icicle-mpfs.cfg
TARGET_DIR=$(CURDIR)/work/binaries
BINARIES_DIR=$(CURDIR)/work
GENIMAGE_TMP=/tmp/genimage-${DEVKIT}

processed_schema := $(linux_wrkdir)/Documentation/devicetree/bindings/processed-schema.json

tftp_boot_scr ?= boot.scr

bootloaders-$(FSBL_SUPPORT) += $(fsbl)
bootloaders-$(OSBI_SUPPORT) += $(opensbi)
bootloaders-$(SECOND_SUPPORT) += $(secondboot)
bootloaders-$(HSS_SUPPORT) += $(hss_uboot_payload_bin)
bootloaders-$(AMP_SUPPORT) += $(amp_example)
bootloaders-$(V5V2_SUPPORT) += $(v5v2_spl)
bootloaders-$(V5V2_SUPPORT) += $(tpl_img)

deploy_dir := $(CURDIR)/deploy

random_date := "@666"

ykurcmd_srcdir := $(srcdir)/ykurcmd
ykurcmd := $(wrkdir)/.ykurcmd
ykush_srcdir := $(srcdir)/ykush
ykush := $(wrkdir)/.ykush
lab_srcdir := $(srcdir)/lab
lab_wrkdir := $(wrkdir)/lab_build
lab_config := $(srcdir)/lab/config.yaml
lab := $(wrkdir)/bin/lab

.PHONY: tftp-boot
tftp-boot:
	$(MAKE) clean-linux DEVKIT=$(DEVKIT)
	$(MAKE) all W=1 C=1 DEVKIT=$(DEVKIT) 2>&1 | tee logs/tftp.log
	cp $(fit) /srv/tftp/$(DEVKIT)-fitImage.fit
	cp $(uboot_s_scr) /srv/tftp/$(DEVKIT)-boot.scr
	cp $(vmlinux_bin) /srv/tftp/$(DEVKIT)-vmlinux.bin
	cp $(uimage) /srv/tftp/$(DEVKIT).uImage
	cd $(linux_srcdir) && ./scripts/clang-tools/gen_compile_commands.py --directory ${linux_wrkdir}
	- cd $(linux_srcdir) && ./scripts/generate_rust_analyzer.py $(linux_srcdir) $(linux_wrkdir) $(rust_sysroot) > rust-project.json

.PHONY: reboot
reboot: $(lab)
	$(lab) -f reset -b $(DEVKIT) -c $(lab_config)

.PHONY: random-config
random-config:
	$(MAKE) clean-linux
	mkdir -p $(linux_wrkdir)
	cp $(CURDIR)/randconfig $(linux_wrkdir)/.config
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) \
		ARCH=riscv \
		CROSS_COMPILE=$(LINUX_CROSS) $(LINUX_LLVM) $(LINUX_IAS) $(LINUX_LLD) $(LINUX_AS) $(LINUX_LD) $(LINUX_CC) \
		PATH=$(PATH) \
		W=1 C=1 \
		KBUILD_BUILD_TIMESTAMP=$(random_date) \
		-j$(num_threads) | tee logs/random.log
	cd $(linux_srcdir) && ./scripts/clang-tools/gen_compile_commands.py --directory ${linux_wrkdir}
	- cd $(linux_srcdir) && ./scripts/generate_rust_analyzer.py $(linux_srcdir) $(linux_wrkdir) $(rust_sysroot) > rust-project.json

.PHONY: allmodconfig
allmodconfig:
	$(MAKE) clean-linux
	mkdir -p $(linux_wrkdir)
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) \
		ARCH=riscv \
		CROSS_COMPILE=$(LINUX_CROSS) $(LINUX_LLVM) $(LINUX_IAS) $(LINUX_LLD) $(LINUX_AS) $(LINUX_LD) $(LINUX_CC) \
		PATH=$(PATH) \
		allmodconfig
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) \
		ARCH=riscv \
		CROSS_COMPILE=$(LINUX_CROSS) $(LINUX_LLVM) $(LINUX_IAS) $(LINUX_LLD) $(LINUX_AS) $(LINUX_LD) $(LINUX_CC) \
		PATH=$(PATH) \
		C=1 \
		-k \
		KBUILD_BUILD_TIMESTAMP=$(random_date) \
		-j$(num_threads) 2>&1 | tee logs/allmodconfig.log
	cd $(linux_srcdir) && ./scripts/clang-tools/gen_compile_commands.py --directory ${linux_wrkdir}
	- cd $(linux_srcdir) && ./scripts/generate_rust_analyzer.py $(linux_srcdir) $(linux_wrkdir) $(rust_sysroot) > rust-project.json

.PHONY: allyesconfig
allyesconfig:
	$(MAKE) clean-linux
	mkdir -p $(linux_wrkdir)
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) \
		ARCH=riscv \
		CROSS_COMPILE=$(LINUX_CROSS) $(LINUX_LLVM) $(LINUX_IAS) $(LINUX_LLD) $(LINUX_AS) $(LINUX_LD) $(LINUX_CC) \
		PATH=$(PATH) \
		allyesconfig
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) \
		ARCH=riscv \
		CROSS_COMPILE=$(LINUX_CROSS) $(LINUX_LLVM) $(LINUX_IAS) $(LINUX_LLD) $(LINUX_AS) $(LINUX_LD) $(LINUX_CC) \
		PATH=$(PATH) \
		C=1 \
		-k \
		KBUILD_BUILD_TIMESTAMP=$(random_date) \
		-j$(num_threads) 2>&1 | tee logs/allyesconfig.log
	cd $(linux_srcdir) && ./scripts/clang-tools/gen_compile_commands.py --directory ${linux_wrkdir}
	- cd $(linux_srcdir) && ./scripts/generate_rust_analyzer.py $(linux_srcdir) $(linux_wrkdir) $(rust_sysroot) > rust-project.json

.PHONY: smatch
smatch:
	$(MAKE) clean-linux
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) \
		ARCH=riscv \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		PATH=$(PATH) \
		defconfig
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) \
		ARCH=riscv \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		PATH=$(PATH) \
		KBUILD_BUILD_TIMESTAMP=$(random_date) \
		C=2 CHECK=$(srcdir)/smatch/smatch \
		$(FILE)

.PHONY: qemu-virt
qemu-virt:
	$(qemu) -M virt \
		-m 2G -smp 5 \
		-nographic \
		-kernel $(vmlinux_bin) \
		-initrd $(initramfs)

.PHONY: qemu-clang
qemu-clang:
	$(qemu) -M virt \
		-nographic \
		-kernel $(vmlinux_bin) \
		-append earlycon \
		-initrd $(initramfs) \
		-m 512m -nodefaults -no-reboot \
		-serial mon:stdio \
		-drive file=$(wrkdir)/stage4-disk.img,format=raw

.PHONY: qemu-icicle
qemu-icicle:
	$(qemu) -M microchip-icicle-kit \
		-m 3G -smp 5 \
		-kernel $(vmlinux_bin) \
		-dtb $(wrkdir)/riscvpc.dtb \
		-initrd $(initramfs) \
		-display none -serial null \
		-serial stdio \
		-D qemu.log -d unimp

.PHONY: qemu-alex
qemu-alex:
	$(qemu) -M virt \
		-cpu rv64,v=true,zbb=true,h=true,sscofpmf=true \
		-m 8G -smp 16 \
		-nographic \
		-kernel $(vmlinux_bin) \
		-initrd $(initramfs) \
		-D qemu.log -d unimp

.PHONY: qemu-arm
qemu-arm:
	$(qemu_arm) -M virt \
		-m 8G -smp 8 \
		-cpu cortex-a72 \
		-nographic \
		-kernel work/Image \
		-append "earlycon root=/dev/vda ro" \
		-D qemu.log -d unimp

.PHONY: qemu-xen
qemu-xen:
	$(qemu) -M virt \
	-cpu rv64,h=true \
	-smp 1 -m 2G \
	-nographic \
	-kernel $(xen) \
	-device 'guest-loader,kernel=$(vmlinux_bin),addr=0x80400000,bootargs=console=hvc0 earlycon=sbi keep_bootcon' \
	-device 'guest-loader,initrd=$(initramfs),addr=0x84000000' \
	-D qemu.log -d unimp


.PHONY: qemu-icicle-hss
qemu-icicle-hss:
	$(qemu) -s -S -M microchip-icicle-kit \
		-m 4G -smp 5 \
		-chardev socket,id=serial1,path=serial1.sock,server=on,wait=on \
		-display none -serial stdio \
		-bios $(wrkdir)/hss-qemu.bin \
		-sd work/sdcard.img \
		-serial chardev:serial1

.PHONY: coccicheck
coccicheck:
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) \
		ARCH=riscv \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		PATH=$(PATH) \
		coccicheck \
		MODE=report M=$(linux_srcdir)/$(DIR)

.PHONY: all_devkits
all_devkits:
	$(MAKE) clean-linux
	$(MAKE) all W=1 DEVKIT=polarberry 2>&1 | tee logs/polarberry.log
	$(MAKE) clean-linux
	- $(MAKE) all W=1 DEVKIT=icicle-kit-es 2>&1 | tee logs/icicle.log
	$(MAKE) clean-linux
	$(MAKE) all W=1 DEVKIT=mainline 2>&1 | tee logs/icicle.log

.PHONY: dtbs_check
dtbs_check:
	$(MAKE) clean-linux
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) \
		ARCH=riscv \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		PATH=$(PATH) \
		defconfig
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) \
		ARCH=riscv \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		PATH=$(PATH) \
		dtbs_check W=1 -j$(num_threads) 2>&1 | tee logs/dtbs_check.log

.PHONY: dt_binding_check
dt_binding_check:
	$(MAKE) clean-linux
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) \
		ARCH=riscv \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		PATH=$(PATH) \
		dt_binding_check -j$(num_threads) 2>&1 | tee logs/dt_binding_check.log

.PHONY: maintainers
maintainers:
	cd $(linux_srcdir) && ./scripts/get_maintainer.pl --self-test=patterns | tee $(srcdir)/logs/maintainers_check.log

.PHONY: compile_commands
compile_commands:
	cd $(linux_srcdir) && ./scripts/clang-tools/gen_compile_commands.py --directory ${linux_wrkdir}

# random crap
.PHONY: payload_ext

.PHONY: vmlinux bbl fit flash_image initrd opensbi u-boot bootloaders dtbs
vmlinux: $(vmlinux_bin)
fit: $(fit)
initrd: $(initramfs)
u-boot: $(hss_uboot_payload_bin)
flash_image: $(flash_image)
opensbi: $(opensbi)
fsbl: $(fsbl)
bootloaders: $(bootloaders-y)
dtbs: ${device_tree_blob}

.PHONY: clean distclean clean-linux clean-workdir

.PHONY: lab
lab: $(lab)
ykush: $(ykush)

$(ykush): $(ykush_srcdir)
	cd $(ykush_srcdir) && ./build.sh
	cd $(ykush_srcdir) && sudo ./install.sh
	touch $@

$(ykurcmd): $(ykurcmd_srcdir)
	cd $(ykurcmd_srcdir) && ./build.sh
	cd $(ykurcmd_srcdir) && sudo ./install.sh
	touch $@

$(lab): $(lab_srcdir) $(ykush) $(ykurcmd)
	cargo install -f \
		--path $(lab_srcdir) \
		-j $(num_threads) \
		--target-dir $(lab_wrkdir) \
		--root $(wrkdir)

all: $(fit) $(vfat_image) $(bootloaders-y)
	@echo ':)'

ifneq ($(GCC_DIR),$(toolchain_dest))
$(CROSS_COMPILE_CC):
	ifeq (,CROSS_COMPILE_CC --version 2>/dev/null)
		$(error The RISCV environment variable was set, but is not pointing at a toolchain install tree)
else
CROSS_COMPILE_CC: $(toolchain_srcdir)
	mkdir -p $(toolchain_wrkdir)
	mkdir -p $(toolchain_wrkdir)/header_workdir
	$(MAKE) -C $(linux_srcdir) O=$(toolchain_wrkdir)/header_workdir \
		ARCH=riscv \
		INSTALL_HDR_PATH=$(abspath $(toolchain_srcdir)/linux-headers) \
		headers_install
	cd $(toolchain_wrkdir); $(toolchain_srcdir)/configure \
		--prefix=$(toolchain_dest) \
		--with-arch=$(ISA) \
		--with-abi=$(ABI) \
		--enable-linux
	$(MAKE) -C $(toolchain_wrkdir) -j$(num_threads)
endif

.PHONY: build-binutils build-llvm build-llvm-pgo sparse qemu-configure qemu-build
build-llvm:
	$(tc_build_dir)/build-llvm.py -b $(llvm_wrkdir)/llvm/ -i $(LLVM_DIR) -l $(llvm_srcdir) -n

build-llvm-pgo:
	$(tc_build_dir)/build-llvm.py -b $(llvm_wrkdir)/llvm/ -i $(LLVM_DIR)-pgo -l $(llvm_srcdir) -n \
		-L$(linux_srcdir) --pgo=kernel-allmodconfig --targets X86 RISCV

build-binutils:
	$(tc_build_dir)/build-binutils.py -b $(binutils_srcdir) -B $(binutils_wrkdir) -i $(BINUTILS_DIR) -t riscv64

sparse:
	$(MAKE) -C $(SPARSE_DIR)

qemu-configure:
	cd $(QEMU_DIR) && ./configure --target-list=riscv64-softmmu

qemu-build: $(qemu)
$(qemu):
	$(MAKE) -C $(QEMU_DIR) -j $(num_threads)

.PHONY: xen
xen: $(xen)
$(xen): $(xen_srcdir) $(CROSS_COMPILE_CC)
	- mkdir -p $(xen_wrkdir)
	$(MAKE) -C $(xen_srcdir) O=$(xen_wrkdir) \
	XEN_TARGET_ARCH=riscv64 \
	CROSS_COMPILE=$(CROSS_COMPILE) \
	PATH=$(PATH) \
	KBUILD_DEFCONFIG=tiny64_defconfig \
	xen

.PHONY: processed-schema qemu-dtbs
processed-schema: dtbs_check
qemu-dtbs: processed-schema
	$(qemu) -smp 4 -M virt,aia=aplic,dumpdtb=$(qemu_dtb) -m 1G -nographic
	dt-validate --schema $(processed_schema) $(qemu_dtb)

$(buildroot_initramfs_wrkdir):
	mkdir -p $(buildroot_initramfs_wrkdir)

$(buildroot_initramfs_wrkdir)/.config: $(buildroot_srcdir) $(buildroot_initramfs_wrkdir) $(confdir)/initramfs.txt $(buildroot_initramfs_config) $(uboot_s_cfg) $(uboot_s_txt) $(opensbi_dyn)
	cp $(buildroot_initramfs_config) $(buildroot_initramfs_wrkdir)/.config
	$(MAKE) -C $(buildroot_srcdir) RISCV=$(GCC_DIR) PATH=$(PATH) \
		O=$(buildroot_initramfs_wrkdir) CROSS_COMPILE=$(CROSS_COMPILE) \
		-j$(num_threads) \
		OPENSBI=$(opensbi_dyn) \
		olddefconfig

$(buildroot_initramfs_tar): $(buildroot_initramfs_wrkdir)/.config CROSS_COMPILE_CC $(buildroot_initramfs_config)
	$(MAKE) -C $(buildroot_srcdir) RISCV=$(GCC_DIR) PATH=$(PATH) \
		O=$(buildroot_initramfs_wrkdir) -j$(num_threads) DEVKIT=$(DEVKIT) \
		OPENSBI=$(opensbi_dyn)

$(buildroot_initramfs_sysroot_stamp): $(buildroot_initramfs_tar)
	mkdir -p $(buildroot_initramfs_sysroot)
	tar -xpf $< -C $(buildroot_initramfs_sysroot) --exclude ./dev --exclude ./usr/share/locale
	touch $@

$(initramfs).d: $(buildroot_initramfs_sysroot) $(kernel-modules-install-stamp)
	cd $(wrkdir) && $(linux_srcdir)/usr/gen_initramfs.sh -l $(confdir)/initramfs.txt $(buildroot_initramfs_sysroot) > $@

$(initramfs_uc): $(buildroot_initramfs_sysroot) $(vmlinux) $(kernel-modules-install-stamp)
	cd $(linux_wrkdir) && \
		$(linux_srcdir)/usr/gen_initramfs.sh \
		-o $@ -u $(shell id -u) -g $(shell id -g) \
		$(confdir)/initramfs.txt \
		$(buildroot_initramfs_sysroot)

$(initramfs): $(initramfs_uc)
	- rm $(initramfs)
	gzip $(initramfs_uc) --keep -q
	mv $(initramfs_uc).gz $(initramfs)

.PHONY: buildroot_initramfs_menuconfig
buildroot_initramfs_menuconfig: $(buildroot_initramfs_wrkdir)/.config
	$(MAKE) -C $(buildroot_srcdir) O=$(buildroot_initramfs_wrkdir) menuconfig
	$(MAKE) -C $(buildroot_srcdir) O=$(buildroot_initramfs_wrkdir) savedefconfig
	cp $(buildroot_initramfs_wrkdir)/defconfig $(buildroot_initramfs_config)

.PHONY: linux_cfg
linux_cfg: $(linux_wrkdir)/.config
$(linux_wrkdir)/.config: $(linux_defconfig) $(linux_fragment) $(linux_srcdir)
	mkdir -p $(dir $@)
ifneq (,$(findstring $(confdir),$(linux_defconfig)))
	cp $(linux_defconfig) $@
	
ifneq (,$(linux_fragment))
	cat $(linux_fragment) >> $@
endif
	
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) CROSS_COMPILE=$(LINUX_CROSS) $(LINUX_LLVM) $(LINUX_IAS) $(LINUX_LLD) $(LINUX_AS) $(LINUX_LD) $(LINUX_CC) ARCH=riscv olddefconfig
else
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) CROSS_COMPILE=$(LINUX_CROSS) $(LINUX_LLVM) $(LINUX_IAS) $(LINUX_LLD) $(LINUX_AS) $(LINUX_LD) $(LINUX_CC) ARCH=riscv $(linux_defconfig)
endif

$(vmlinux): $(linux_wrkdir)/.config $(CROSS_COMPILE_CC)
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) \
		ARCH=riscv \
		CROSS_COMPILE=$(LINUX_CROSS) $(LINUX_LLVM) $(LINUX_IAS) $(LINUX_LLD) $(LINUX_AS) $(LINUX_LD) $(LINUX_CC) \
		PATH=$(PATH) \
		KBUILD_BUILD_TIMESTAMP=$(random_date) \
		-j$(num_threads)

$(vmlinux_stripped): $(vmlinux)
	PATH=$(PATH) $(CROSS_COMPILE)strip -o $@ $<

$(vmlinux_bin): $(vmlinux)
	if [ -f $(vmlinux_relocs) ]; then \
		PATH=$(PATH) $(CROSS_COMPILE)objcopy -O binary $(vmlinux).relocs $@ ;\
	else \
		PATH=$(PATH) $(CROSS_COMPILE)objcopy -O binary $< $@ ;\
	fi

.PHONY: kernel-modules kernel-modules-install
$(kernel-modules-stamp): $(vmlinux)
	touch $@

$(kernel-modules-install-stamp): $(linux_srcdir) $(buildroot_initramfs_sysroot) $(kernel-modules-stamp)
	rm -rf $(buildroot_initramfs_sysroot)/lib/modules/
	$(MAKE) -C $< O=$(linux_wrkdir) \
		ARCH=riscv \
		CROSS_COMPILE=$(LINUX_CROSS) $(LINUX_CC) \
		PATH=$(PATH) \
		modules_install -j$(num_threads) \
		INSTALL_MOD_PATH=$(buildroot_initramfs_sysroot)
	touch $@
	
.PHONY: linux-menuconfig
linux-menuconfig: $(linux_wrkdir)/.config
	$(MAKE) -C $(linux_srcdir) O=$(dir $<) ARCH=riscv menuconfig CROSS_COMPILE=$(LINUX_CROSS) $(LINUX_LLVM) $(LINUX_IAS) $(LINUX_LLD) $(LINUX_AS) $(LINUX_LD) $(LINUX_CC)
	$(MAKE) -C $(linux_srcdir) O=$(dir $<) ARCH=riscv savedefconfig CROSS_COMPILE=$(LINUX_CROSS) $(LINUX_LLVM) $(LINUX_IAS) $(LINUX_LLD) $(LINUX_AS) $(LINUX_LD) $(LINUX_CC)
	cp $(dir $<)/defconfig $(linux_defconfig)

$(device_tree_blob): $(vmlinux)
	$(MAKE) -C $(linux_srcdir) O=$(linux_wrkdir) CROSS_COMPILE=$(LINUX_CROSS) $(LINUX_LLVM) $(LINUX_IAS) $(LINUX_LLD) $(LINUX_AS) $(LINUX_LD) $(LINUX_CC) ARCH=riscv dtbs
	cp $(linux_dtb) $(device_tree_blob)

$(fit): $(uboot_s) $(uimage) $(vmlinux_bin) $(initramfs) $(device_tree_blob) $(its_file) $(kernel-modules-install-stamp)
	PATH=$(PATH) mkimage -f $(its_file) -A riscv -O linux -T flat_dt $@

$(uimage): $(initramfs)
	mkimage -A riscv -O linux -T ramdisk -C gzip -d $< $@

# bootloaders

$(libversion): $(fsbl_wrkdir_stamp)
	- rm -rf $(libversion)
	echo "const char *gitid = \"$(shell git describe --always --dirty)\";" > $(libversion)
	echo "const char *gitdate = \"$(shell git log -n 1 --date=short --format=format:"%ad.%h" HEAD)\";" >> $(libversion)
	echo "const char *gitversion = \"$(shell git rev-parse HEAD)\";" >> $(libversion)

$(fsbl_wrkdir_stamp): $(fsbl_srcdir) $(fsbl_patchdir)
	- rm -rf $(fsbl_wrkdir)
	mkdir $(fsbl_wrkdir) -p && cd $(fsbl_wrkdir) && cp $(fsbl_srcdir)/* . -r
	for file in $(fsbl_patchdir)/* ; do \
			cd $(fsbl_wrkdir) && patch -p1 < $${file} ; \
	done
	touch $@

$(fsbl): $(libversion) $(fsbl_wrkdir_stamp) $(device_tree_blob)
	rm -f $(fsbl_wrkdir)/fsbl/ux00_fsbl.dts
	cp -f $(device_tree_blob) $(fsbl_wrkdir)/fsbl/ux00_fsbl.dtb
	$(MAKE) -C $(fsbl_wrkdir) O=$(fsbl_wrkdir) CROSSCOMPILE=$(CROSS_COMPILE) all -j$(num_threads)
	cp $(fsbl_wrkdir)/fsbl.bin $(fsbl)
	
$(uboot_s): $(buildroot_initramfs_sysroot_stamp)

$(opensbi_dyn_build): CROSS_COMPILE_CC
	mkdir -p $(opensbi_wrkdir)
	$(MAKE) -C $(opensbi_srcdir) O=$(opensbi_wrkdir) CROSS_COMPILE=$(CROSS_COMPILE) \
		PLATFORM=generic -j $(num_threads)

$(opensbi_dyn): $(opensbi_dyn_build)
	cp $(opensbi_dyn_build) $@

opensbi_build := $(opensbi_wrkdir)/platform/generic/firmware/fw_payload.bin
$(opensbi_build): $(uboot_s) CROSS_COMPILE_CC
	mkdir -p $(opensbi_wrkdir)
	mkdir -p $(dir $@)
	$(MAKE) -C $(opensbi_srcdir) O=$(opensbi_wrkdir) CROSS_COMPILE=$(CROSS_COMPILE) \
		PLATFORM=generic FW_PAYLOAD_PATH=$(uboot_s) \
		 -j $(num_threads)

$(opensbi): $(opensbi_build)
	cp $(opensbi_build) $@

$(secondboot): $(opensbi)
	cd $(wrkdir) && $(second_srcdir)/build/fsz.sh $(opensbi)
	touch $(secondboot)

$(tpl_img): $(u-boot) $(opensbi)
	mkimage -f $(tpl_its) -A riscv -O u-boot -T firmware $@
	cp $@ /srv/tftp/

$(v5v2_spl_tool): $(v5v2_spl_tool_srcdir)
	cd $(v5v2_spl_tool_srcdir) && make

$(v5v2_spl): $(uboot_spl) $(v5v2_spl_tool)
	$(v5v2_spl_tool) -c -f $<
	cp $(v5v2_spl_interim) $@

$(buildroot_initramfs_sysroot): $(buildroot_initramfs_sysroot_stamp)

$(payload_generator_tarball):
	mkdir -p $(srcdir)/br-dl-dir/
	wget $(payload_generator_url) -O $(payload_generator_tarball) --show-progress

$(hss_payload_generator): $(payload_generator_tarball)
	- rm -rf $(wrkdir)/payload_gen
	unzip $(payload_generator_tarball) -d $(wrkdir)/payload_gen
	cp $(wrkdir)/payload_gen/hss-payload-generator/binaries/hss-payload-generator $(wrkdir)

$(hss_uboot_payload_bin): $(uboot_s) $(hss_payload_generator) $(bootloaders-y)
	cd $(buildroot_initramfs_wrkdir)/images && $(hss_payload_generator) -c $(payload_config) -v $(hss_uboot_payload_bin)

payload_ext: $(uboot_s) $(hss_payload_generator) $(bootloaders-y)
	cd $(wrkdir) && $(hss_payload_generator) -c $(payload_config) -v $(hss_uboot_payload_bin)

# random crap

clean: clean-linux
	rm -rf -- $(wrkdir)/$(DEVKIT) $(initramfs_uc)

clean-workdir:
	rm -rf -- $(wrkdir)

clean-linux:
	rm -rf -- $(fit) $(device_tree_blob) $(vfat_image) $(kernel-modules-stamp) $(initramfs) $(initramfs_uc) $(kernel-modules-install-stamp) $(vmlinux_bin) $(linux_wrkdir) $(hss_uboot_payload_bin)

distclean:
	rm -rf -- $(wrkdir) $(toolchain_dest) br-dl-dir/ arch/ include/ scripts/ .cache.mk

.PHONY: gdb
gdb: $(target_gdb)

.PHONY: openocd
openocd: $(openocd)
	$(openocd) -f $(confdir)/u540-openocd.cfg

$(openocd): $(openocd_srcdir)
	rm -rf $(openocd_wrkdir)
	mkdir -p $(openocd_wrkdir)
	mkdir -p $(dir $@)
	cd $(openocd_srcdir) && ./bootstrap
	cd $(openocd_wrkdir) && $</configure --enable-maintainer-mode --disable-werror --enable-ft2232_libftdi
	$(MAKE) -C $(openocd_wrkdir)

EXT_CFLAGS := -DMPFS_HAL_FIRST_HART=4 -DMPFS_HAL_LAST_HART=4
export EXT_CFLAGS
.PHONY: amp
amp: $(amp_example)
$(amp_example): $(amp_example_srcdir) $(buildroot_initramfs_sysroot_stamp) CROSS_COMPILE_CC
	rm -rf $(amp_example_srcdir)/Default
	$(MAKE) -C $(amp_example_srcdir) O=$(amp_example_wrkdir) CROSS_COMPILE=$(CROSS_COMPILE) REMOTE=1
	cp $(amp_example_srcdir)/Remote-Default/mpfs-rpmsg-remote.elf $(amp_example)

$(vfat_image): $(fit) $(uboot_s_scr) $(bootloaders-y)
	@if [ `du --apparent-size --block-size=512 $(fsbl) | cut -f 1` -ge $(FSBL_SIZE) ]; then \
		echo "FSBL is too large for partition!!\nReduce fsbl or increase partition size"; \
		rm $(flash_image); exit 1; fi
	dd if=/dev/zero of=$(vfat_image) bs=512 count=$(VFAT_SIZE)
	/sbin/mkfs.vfat $(vfat_image)
	PATH=$(PATH) MTOOLS_SKIP_CHECK=1 mcopy -i $(vfat_image) $(fit) ::fitImage.fit
	PATH=$(PATH) MTOOLS_SKIP_CHECK=1 mcopy -i $(vfat_image) $(uboot_s_scr) ::boot.scr

## sd/emmc/envm formatting

# partition addreses for mpfs
BBL		= 2E54B353-1271-4842-806F-E436D6AF6985
VFAT		= EBD0A0A2-B9E5-4433-87C0-68B6B72699C7
LINUX		= 0FC63DAF-8483-4772-8E79-3D69D8477DE4
FSBL		= 5B193300-FC78-40CD-8002-E86C45580B47
UBOOT		= 5B193300-FC78-40CD-8002-E86C45580B47
UBOOTENV	= a09354ac-cd63-11e8-9aff-70b3d592f0fa
UBOOTDTB	= 070dd1a8-cd64-11e8-aa3d-70b3d592f0fa
UBOOTFIT	= 04ffcafa-cd65-11e8-b974-70b3d592f0fa
HSS_PAYLOAD 	= 21686148-6449-6E6F-744E-656564454649

# partition addreses
UENV_START=100
UENV_END=1023
FSBL_START=2048
FSBL_END=4095
FSBL_SIZE=2048
VFAT_START=4096
VFAT_END=184023
VFAT_SIZE=179928
RESERVED_SIZE=2000
OSBI_START=185648
OSBI_END=219024

# partition addreses for icicle kit
UBOOT_START=2048
UBOOT_END=23248
LINUX_START=24096
LINUX_END=208119
ROOT_START=209119

.PHONY: format-icicle-image
format-icicle-image: $(fit) $(uboot_s_scr)
	@test -b $(DISK) || (echo "$(DISK): is not a block device"; exit 1)
	$(eval DEVICE_NAME := $(shell basename $(DISK)))
	$(eval SD_SIZE := $(shell cat /sys/block/$(DEVICE_NAME)/size))
	$(eval ROOT_SIZE := $(shell expr $(SD_SIZE) \- $(RESERVED_SIZE)))
	/sbin/sgdisk -Zo  \
    --new=1:$(UBOOT_START):$(UBOOT_END) --change-name=1:uboot --typecode=1:$(HSS_PAYLOAD) \
    --new=2:$(LINUX_START):$(LINUX_END) --change-name=2:kernel --typecode=2:$(LINUX) \
    --new=3:$(ROOT_START):${ROOT_SIZE} --change-name=3:root	--typecode=2:$(LINUX) \
    ${DISK}	
	-/sbin/partprobe
	@sleep 1
	
ifeq ($(DISK)1,$(wildcard $(DISK)1))
	@$(eval partition_prefix := )
else ifeq ($(DISK)s1,$(wildcard $(DISK)s1))
	@$(eval partition_prefix := s)
else ifeq ($(DISK)p1,$(wildcard $(DISK)p1))
	@$(eval partition_prefix := p)
else
	@echo Error: Could not find bootloader partition for $(DISK)
	@exit 1
endif

	dd if=$(hss_uboot_payload_bin) of=$(DISK)$(partition_prefix)1
	dd if=$(vfat_image) of=$(DISK)$(partition_prefix)2

# mpfs
.PHONY: format-boot-loader
format-boot-loader: $(fit) $(vfat_image) $(bootloaders-y)
	@test -b $(DISK) || (echo "$(DISK): is not a block device"; exit 1)
	$(eval DEVICE_NAME := $(shell basename $(DISK)))
	$(eval SD_SIZE := $(shell cat /sys/block/$(DEVICE_NAME)/size))
	$(eval ROOT_SIZE := $(shell expr $(SD_SIZE) \- $(RESERVED_SIZE)))
	/sbin/sgdisk -Zo  \
		--new=1:$(FSBL_START):$(FSBL_END)   --change-name=1:fsbl	--typecode=1:$(FSBL) \
		--new=2:$(VFAT_START):$(VFAT_END)  --change-name=2:"Vfat Boot"	--typecode=2:$(VFAT)   \
		--new=3:$(OSBI_START):$(OSBI_END)  --change-name=3:osbi	--typecode=3:$(BBL) \
		--new=4:264192:$(ROOT_SIZE) --change-name=4:root	--typecode=4:$(LINUX) \
		$(DISK)
	-/sbin/partprobe
	@sleep 1
ifeq ($(DISK)p1,$(wildcard $(DISK)p1))
	@$(eval PART1 := $(DISK)p1)
	@$(eval PART2 := $(DISK)p2)
	@$(eval PART3 := $(DISK)p3)
	@$(eval PART4 := $(DISK)p4)
else ifeq ($(DISK)s1,$(wildcard $(DISK)s1))
	@$(eval PART1 := $(DISK)s1)
	@$(eval PART2 := $(DISK)s2)
	@$(eval PART3 := $(DISK)s3)
	@$(eval PART4 := $(DISK)s4)
else ifeq ($(DISK)1,$(wildcard $(DISK)1))
	@$(eval PART1 := $(DISK)1)
	@$(eval PART2 := $(DISK)2)
	@$(eval PART3 := $(DISK)3)
	@$(eval PART4 := $(DISK)4)
else
	@echo Error: Could not find bootloader partition for $(DISK)
	@exit 1
endif

	dd if=$(fsbl) of=$(PART1) bs=4096
	dd if=$(vfat_image) of=$(PART2) bs=4096
	dd if=$(opensbi) of=$(PART3) bs=4096

.PHONY: genimage-icicle-image
genimage-icicle-image: $(fit) $(uboot_s_scr)
	rm -rf $(GENIMAGE_TMP)
	mkdir -p $(GENIMAGE_TMP)
	$(CURDIR)/work/$(DEVKIT)/buildroot_initramfs/host/bin/genimage \
		--rootpath "${TARGET_DIR}" \
		--tmppath "${GENIMAGE_TMP}" \
		--inputpath "${BINARIES_DIR}" \
		--outputpath "${BINARIES_DIR}" \
		--config "${GENIMAGE_CFG}"
