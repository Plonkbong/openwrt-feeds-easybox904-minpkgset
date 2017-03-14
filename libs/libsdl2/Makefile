#
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=SDL2
PKG_VERSION:=2.0.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.libsdl.org/release/
#PKG_MD5SUM:=e52086d1b508fa0b76c52ee30b55bec4

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

TARGET_CFLAGS += -Wno-error -Wno-error=declaration-after-statement

include $(INCLUDE_DIR)/package.mk

define Package/libsdl2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Simple DirectMedia Layer 2
  URL:=http://www.libsdl.org
  DEPENDS:=+zlib +libpthread +directfb
endef

define Package/libsdl2/description
 SDL is a library that allows programs portable low level access to a video
 framebuffer, audio output, mouse, and keyboard.
endef

CONFIGURE_ARGS+= \
	--enable-libc \
	--enable-video \
	--enable-events \
	--disable-joystick \
	--enable-threads \
	--enable-timers \
	--enable-file \
	--enable-loadso \
	--enable-cpuinfo \
	--enable-assembly \
	--disable-oss \
	--disable-alsatest \
	--disable-alsa-shared \
	--disable-esd \
	--disable-esdtest \
	--disable-esd-shared \
	--disable-pulseaudio \
	--disable-pulseaudio-shared \
	--disable-arts \
	--disable-arts-shared \
	--disable-nas \
	--disable-nas-shared \
	--disable-diskaudio \
	--disable-dummyaudio \
	--disable-altivec \
	--disable-video-x11 \
	--disable-x11-shared \
	--disable-video-x11-vm \
	--disable-video-x11-xinerama \
	--disable-video-x11-xrandr \
	--disable-video-cocoa \
	--enable-video-directfb \
	--enable-directfb-shared \
	--disable-video-dummy \
	--disable-video-opengl \
	--disable-input-tslib \
	--enable-pthreads \
	--enable-pthread-sem \
	--disable-directx \
	--enable-sdl-dlopen \
	--disable-clock_gettime \
	--without-x \
	--disable-rpath \
	--disable-audio \
	--disable-alsa

CONFIGURE_VARS+= \
		ac_cv_path_DIRECTFBCONFIG=no \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/SDL* \
		$(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libSDL*.{a,so*} \
		$(1)/usr/lib/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* \
		$(1)/usr/lib/pkgconfig


	$(INSTALL_DIR) $(1)/usr/share/aclocal
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/aclocal/* \
		$(1)/usr/share/aclocal/

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/sdl2-config \
		$(1)/usr/bin/

	$(SED) 's,^\(exec_prefix\|prefix\)=.*,\1=\"$(STAGING_DIR)/usr/\",g' \
		$(1)/usr/bin/sdl2-config

	$(INSTALL_DIR) $(1)/host/bin
	ln -sf ../../usr/bin/sdl2-config $(1)/host/bin/
endef

define Package/libsdl2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libSDL*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libsdl2))
