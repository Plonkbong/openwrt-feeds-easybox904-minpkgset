#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ralink_bin
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/RT3883
PKG_SOURCE:=cfg.tar.xz
PKG_SOURCE_URL:=https://github.com/Quallenauge/ralink_inic/releases/download/1.0.0

PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk

define Package/ralink_bin/Default
  SECTION:=kernel
  CATEGORY:=Kernel modules
#  DEPENDS:=
  SUBMENU:=Proprietary Easybox 904 xDSL WiFi driver
  SECTION:=kernel
  DEPENDS:=+wireless-tools
  TITLE:=Kernel driver for ralink chipsets

endef

define Package/ralink_bin
  $(call Package/ralink_bin/Default)
#FILES:=$(PKG_BUILD_DIR)/rt3883_iNIC.ko
endef

WMENU:=Wireless Drivers

define Package/ralink_bin/Default/description
 This package contains additional files for the
 proprietary wireless driver of Easybox 904 xDSL.
endef

define Package/ralink_bin
$(call Package/ralink_bin/Default,)
  SUBMENU:=$(WMENU)
  TITLE+= (normal version)
endef

define Package/ralink_bin/description
$(call Package/ralink_bin/Default/description)
endef

define Build/Prepare
	$(call Build/Prepare/Default)
endef

define Build/Compile
#	# Compile the kernel part
#	$(MAKE_KMOD) \
#		SUBDIRS="$(PKG_BUILD_DIR)" \
#		MODFLAGS="-DMODULE -mlong-calls" \
#		modules
endef

define Package/ralink_bin/install
	#$(INSTALL_DIR) $(1)/etc/init.d
	#$(INSTALL_DIR) $(1)/lib/modules/$(LINUX_VERSION)
#	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/lib/firmware/iNIC/RT3883
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/*.bin $(1)/lib/firmware/iNIC/RT3883/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/*.dat $(1)/lib/firmware/iNIC/RT3883/
#	$(CP) $(PKG_BUILD_DIR)/tools/{madwifi_multi,80211debug,80211stats,athchans,athctrl,athdebug,athkey,athstats,wlanconfig} $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,ralink_bin))
