#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-event
PKG_VERSION:=0.4.4
PKG_RELEASE:=1
PKG_MAINTAINER:=Quallenauge <Hamsi2k@freenet.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_URL:=https://github.com/harningt/luaevent.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_VERSION:=v0.4.4

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=lua/host

include $(INCLUDE_DIR)/package.mk

define Package/lua-event
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Event Lua module
  URL:=https://github.com/Tangent128/lua-event
  DEPENDS:= +lua +libc +libevent2
endef

define Package/lua-event/description
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

define Package/lua-event/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luaevent
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core.so $(1)/usr/lib/lua/luaevent/

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/*.lua $(1)/usr/lib/lua/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,lua-event))
