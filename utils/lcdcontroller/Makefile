#
# Copyright (C) 2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lcdcontroller
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/lcdcontroller
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=LCD Controller
  DEPENDS:=@DISPLAY_SUPPORT +lua +libc +lua-evdev +lua-lalarm
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/lcdcontroller/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,lcdcontroller))
