all: Release
debug:
	xcodebuild -derivedDataPath $(PWD) -configuration Debug -scheme RsyncOSX
release:
	xcodebuild -derivedDataPath $(PWD) -configuration Release -scheme RsyncOSX
clean:
	rm -Rf Build
