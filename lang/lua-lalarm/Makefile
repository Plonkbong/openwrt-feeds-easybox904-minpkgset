#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-lalarm
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Quallenauge <Hamsi2k@freenet.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_URL:=http://webserver2.tecgraf.puc-rio.br/~lhf/ftp/lua/5.1
PKG_SOURCE:=lalarm.tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/alarm
PKG_BUILD_DEPENDS:=lua/host
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_HASH:=0ebd8d07c07c58a30c7239ea2a17e5cd56ff4e5fd21727f31275fd0b50d29209

include $(INCLUDE_DIR)/package.mk

define Package/lua-lalarm
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=lalarm Lua module
  URL:=http://webserver2.tecgraf.puc-rio.br/~lhf/ftp/lua/#lalarm
  DEPENDS:= +lua +libc
endef

define Package/lua-lalarm/description
   An alarm library for Lua based on POSIX alarm.
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
                OPT_FLAGS="$(TARGET_CFLAGS) --std=c99" \
                so
endef

define Package/lua-lalarm/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/alarm.so $(1)/usr/lib/lua/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,lua-lalarm))
