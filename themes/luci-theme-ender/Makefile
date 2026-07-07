#
# Copyright (C) 2026 EnderWRT Project
#
# This is free software, licensed under the Apache License, Version 2.0.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-theme-ender
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_LICENSE:=Apache-2.0

include $(INCLUDE_DIR)/package.mk

define Package/luci-theme-ender
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=4. Themes
  TITLE:=EnderWRT Material Design 3 Theme
  DEPENDS:=+luci-base
endef

define Package/luci-theme-ender/description
  EnderWRT custom theme for LuCI web interface, styled with Material Design 3 guidelines.
endef

define Build/Compile
endef

define Package/luci-theme-ender/install
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/www/luci-static/ender
	$(INSTALL_DIR) $(1)/usr/share/ucode/template/themes/ender

	$(CP) ./root/* $(1)/
	$(CP) ./htdocs/luci-static/ender/* $(1)/www/luci-static/ender/
	$(CP) ./ucode/template/themes/ender/* $(1)/usr/share/ucode/template/themes/ender/
endef

define Package/luci-theme-ender/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/uci-defaults/luci-theme-ender
	rm -f /var/luci-indexcache
fi
exit 0
endef

$(eval $(call BuildPackage,luci-theme-ender))
