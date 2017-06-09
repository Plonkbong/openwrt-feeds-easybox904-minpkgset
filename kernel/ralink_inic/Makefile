#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=ralink_inic
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(ARCH).tar.bz2
#PKG_SOURCE_URL:=https://github.com/kovz/ralink_inic.git
PKG_SOURCE_URL:=https://github.com/Quallenauge/ralink_inic.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=feature/lede_integration

PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk

define Package/ralink_inic/Default
  SECTION:=kernel
  CATEGORY:=Kernel modules
#  DEPENDS:=
  SUBMENU:=Proprietary Easybox 904 xDSL WiFi driver
endef

define KernelPackage/ralink_inic/Default
  $(call Package/ralink_inic/Default)
  SECTION:=kernel
  DEPENDS:=+wireless-tools
  TITLE:=Kernel driver for ralink chipsets
  FILES:=$(PKG_BUILD_DIR)/rt3883_iNIC.ko
#AUTOLOAD:=$(call AutoLoad,30,rt3883_iNIC.ko)
endef

WMENU:=Wireless Drivers

define KernelPackage/ralink_inic/Default/description
 This package contains the proprietary wireless driver for the
 Easybox 904 xDSL.
endef

define KernelPackage/ralink_inic
$(call KernelPackage/ralink_inic/Default,)
  SUBMENU:=$(WMENU)
  TITLE+= (normal version)
endef

define KernelPackage/ralink_inic/description
$(call KernelPackage/ralink_inic/Default/description)
endef

MAKE_KMOD := $(MAKE) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) \
		PATH="$(TARGET_PATH)" \
		SUBDIRS="$(PKG_BUILD_DIR)/kmod" \

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

define KernelPackage/ralink_inic/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/lib/modules/$(LINUX_VERSION)
#	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/etc/init.d/rt3883.init $(1)/etc/init.d/rt3883
	$(INSTALL_DIR) $(1)/lib/wifi
	$(INSTALL_BIN) ./files/lib/wifi/ralink.sh $(1)/lib/wifi
#	$(CP) $(PKG_BUILD_DIR)/tools/{madwifi_multi,80211debug,80211stats,athchans,athctrl,athdebug,athkey,athstats,wlanconfig} $(1)/usr/sbin/
endef

$(eval $(call KernelPackage,ralink_inic))
