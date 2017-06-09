#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=keyboard-eb904
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk

INPUT_MODULES_MENU:=Input modules

define KernelPackage/keyboard-eb904
  SUBMENU:=$(INPUT_MODULES_MENU)
  TITLE:=EasyBox 904 keypad support
  DEPENDS:=@(TARGET_lantiq_xrx200_DEVICE_VGV952CJW33-E-IR) +kmod-input-matrixkmap +kmod-i2c-core +kmod-i2c-algo-bit +kmod-i2c-algo-bit +kmod-i2c-gpio-custom
  KCONFIG:= \
	CONFIG_KEYBOARD_EB904=m \
	CONFIG_INPUT_KEYBOARD=y
  FILES:=$(PKG_BUILD_DIR)/eb904_keypad.ko
  AUTOLOAD:=$(call AutoLoad,60,eb904_keypad)
endef

define KernelPackage/keyboard-eb904/description
 Enable support for EasyBox 904 keypad port.
endef

MAKE_KMOD := $(MAKE) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) \
                PATH="$(TARGET_PATH)" \
                SUBDIRS="$(PKG_BUILD_DIR)/kmod"

define Build/Prepare
	$(call Build/Prepare/Default)
endef

define Build/Compile
	# Compile the kernel part
	$(MAKE_KMOD) \
		SUBDIRS="$(PKG_BUILD_DIR)" \
		MODFLAGS="-DMODULE -mlong-calls" \
		modules
endef
$(eval $(call KernelPackage,keyboard-eb904))
