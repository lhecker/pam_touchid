XCODE = $(shell xcode-select -p)
MODULE_NAME := pam_touchid
LIBRARY_NAME := $(MODULE_NAME).so.2
DESTINATION := /usr/local/lib/pam

$(LIBRARY_NAME): src/Bridging-Header.h src/main.swift
	$(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc \
		-target x86_64-apple-macosx10.13 \
		-sdk $(XCODE)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk \
		-emit-library \
		-swift-version 4 \
		-static-stdlib \
		-O \
		-whole-module-optimization \
		-Xlinker -S \
		-Xlinker -x \
		-Xlinker -dead_strip \
		-Xlinker -dead_strip_dylibs \
		-Xlinker -exported_symbols_list -Xlinker src/export_list \
		-module-name $(MODULE_NAME) \
		-o $(LIBRARY_NAME) \
		-import-objc-header src/Bridging-Header.h \
		src/main.swift

.PHONY: install
install: $(LIBRARY_NAME)
	mkdir -p $(DESTINATION)
	cp $(LIBRARY_NAME) $(DESTINATION)/$(LIBRARY_NAME)
	chmod 755 $(DESTINATION)/$(LIBRARY_NAME)
	chown root:wheel $(DESTINATION)/$(LIBRARY_NAME)

.PHONY: uninstall
uninstall:
	rm $(DESTINATION)/$(LIBRARY_NAME)

.PHONY: clean
clean:
	rm $(LIBRARY_NAME)
