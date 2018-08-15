all: release
debug:
	xcodebuild -derivedDataPath $(PWD) -configuration Debug -scheme RsyncOSX
release:
	xcodebuild -derivedDataPath $(PWD) -configuration Release -scheme RsyncOSX
dmg:
	xcodebuild -derivedDataPath $(PWD) -configuration Release -scheme rsyncosx-dmg
clean:
	rm -Rf Build
	rm -Rf ModuleCache.noindex
	rm -Rf info.plist
	rm -Rf Logs
