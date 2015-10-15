include theos/makefiles/common.mk

BUNDLE_NAME = ReachOffset
ReachOffset_FILES = ReachOffset.mm
ReachOffset_INSTALL_PATH = /Library/PreferenceBundles
ReachOffset_FRAMEWORKS = UIKit MessageUI
ReachOffset_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ReachOffset.plist$(ECHO_END)
