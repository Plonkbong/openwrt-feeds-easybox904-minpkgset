# 
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fbida
PKG_VERSION:=2.08
#PKG_VERSION:=2.14

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.kraxel.org/releases/fbida/
#PKG_MD5SUM:=3e05910fb7c1d9b2bd3e272d96db069c
PKG_HASH:=298e7f3545e33596a5876f6b9c3da7ef475c2692e5fab0df824fbcd7a489cd80
#PKG_HASH:=95b7c01556cb6ef9819f358b314ddfeb8a4cbe862b521a3ed62f03d163154438

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/fbida
    SUBMENU:=fbida
    SECTION:=utils
    CATEGORY:=Utilities
    URL:=https://www.kraxel.org/blog/linux/fbida
    DEPENDS:=+libpng +libtiff +libexif $(ICONV_DEPENDS) +dejavu-fonts-ttf-DejaVuSansMono +libcurl +libfreetype +fontconfig
endef

define Package/fbida/description
    The fbida project contains a few applications for viewing and editing images
endef

define Package/fbi
	$(call Package/fbida)
	TITLE:=This is a image viewer for the linux framebuffer console.
endef

define Package/fbgs
    $(call Package/fbida)
    TITLE:=A wrapper script for viewing ps/pdf files on the framebuffer console using fbi.
    DEPENDS:=+fbi +ghostscript
endef

TARGET_LDFLAGS+=-Wl,-rpath-link=$(STAGING_DIR)/usr/lib -liconv

PKG_CFLAGS=$(TARGET_CFLAGS) -Wall -Wmissing-prototypes \
        -Wstrict-prototypes -Wpointer-arith -Wunused \
        -I. -Wno-pointer-sign -Ijpeg/80 \
        -DHAVE_ENDIAN_H -DHAVE_STRSIGNAL -DHAVE_NEW_EXIF -DHAVE_STRCASESTR \
        -DHAVE_LIBCURL -Wno-error=format-security

define Build/Compile
    $(MAKE) -C $(PKG_BUILD_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(PKG_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG_LIBDIR=/usr/lib/pkgconfig \
	PKG_CONFIG_PATH="/usr/lib/pkgconfig" \
	verbose=yes
endef

define Package/fbi/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/{fbi,exiftran} $(1)/usr/bin/
endef

define Package/fbgs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fbgs $(1)/usr/bin/
endef

$(eval $(call BuildPackage,fbi))
$(eval $(call BuildPackage,fbgs))
