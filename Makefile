export ARCHS = armv7 arm64
export TARGET = iphone:clang:latest:latest

PACKAGE_VERSION = 1.2

include theos/makefiles/common.mk

TWEAK_NAME = ReachOffset
ReachOffset_FILES = Tweak.xm
ReachOffset_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += reachoffset
include $(THEOS_MAKE_PATH)/aggregate.mk
