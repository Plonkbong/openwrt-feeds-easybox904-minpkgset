#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-evdev
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Quallenauge <Hamsi2k@freenet.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_URL:=https://github.com/Tangent128/lua-evdev.git
#PKG_SOURCE_URL:=https://github.com/zhangxiangxiao/lua-evdev.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_VERSION:=Makefiles

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=lua/host luac/host

include $(INCLUDE_DIR)/package.mk

define Package/lua-evdev
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Evdev Lua module
  URL:=https://github.com/Tangent128/lua-evdev
  DEPENDS:= +lua +libc
endef

define Package/lua-evdev/description
  Lua module for reading Linux input events from /dev/input/eventXX nodes
endef

TARGET_CFLAGS += $(FPIC) -Wno-error
# add make variable overrides here
MAKE_FLAGS +=

define Build/Compile
        CFLAGS="$(TARGET_CFLAGS) $(EXTRA_CPPFLAGS) " \
        LDFLAGS="$(EXTRA_LDFLAGS) " \
        $(MAKE) -C $(PKG_BUILD_DIR) \
                CC="$(TARGET_CC)" \
                LD="$(TARGET_CROSS)ld" \
                CROSS="$(TARGET_CROSS)" \
                CXXFLAGS="$(TARGET_CFLAGS) $(EXTRA_CPPFLAGS) " \
                ARCH="$(ARCH)" \
                DESTDIR="$(PKG_INSTALL_DIR)" \
                OPT_FLAGS="$(TARGET_CFLAGS) --std=c99"
endef

define Package/lua-evdev/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/evdev
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/evdev/core.so $(1)/usr/lib/lua/evdev/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/evdev/constants.lua $(1)/usr/lib/lua/evdev/

	$(INSTALL_DIR) $(1)/usr/lib/lua/evdev
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/*.lua $(1)/usr/lib/lua/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,lua-evdev))
