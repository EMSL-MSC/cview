#!/bin/sh

# Author: Brock Erwin
# Install/Uninstall cview file associations

usage() {
	echo Usage: $0 -i
	echo '       This installs cview associations and icons and must be run as root.'
	echo '       I have tested this on RedHat and Ubuntu, and should work in both places.'
	echo Usage: $0 -u
	echo '       This uninstalls cview associations. Must be run as root.'
	exit 1
}

if [ ${#@} -eq 0 ]; then
	usage
elif [ "$1" = "-i" ]; then
	MODE="install"
elif [ "$1" = "-u" ]; then
	MODE="uninstall"
else
	usage
fi

if [ `whoami` != "root" ]; then
	usage
fi

echo "Performing an $MODE"

set -x

if [ "$MODE" = "install" ]; then
	install -m 644 icon64.png "/usr/share/icons/hicolor/64x64/apps/application-x-cview.png"
	install -m 644 icon64.png "/usr/share/icons/hicolor/64x64/apps/application-x-cviewall.png"
	install -m 644 icon64.png "/usr/share/icons/hicolor/64x64/mimetypes/application-x-cview.png"
	install -m 644 icon64.png "/usr/share/icons/hicolor/64x64/mimetypes/application-x-cviewall.png"
	install -m 644 cview-mimetype.xml /usr/share/mime/packages
	install -m 644 cviewall-mimetype.xml /usr/share/mime/packages
	desktop-file-install --dir=/usr/share/applications --vendor=cview cview.desktop
	desktop-file-install --dir=/usr/share/applications --vendor=cview cviewall.desktop
	TMPFILE=`mktemp`
	cat /usr/share/applications/defaults.list > $TMPFILE
	grep -q 'application/x-cview=cview.desktop' $TMPFILE || echo 'application/x-cview=cview.desktop' >> $TMPFILE
	grep -q 'application/x-cviewall=cviewall.desktop' $TMPFILE || echo 'application/x-cviewall=cviewall.desktop' >> $TMPFILE
	sort $TMPFILE > /usr/share/applications/defaults.list
	rm $TMPFILE
else
	for x in "/usr/share/icons/hicolor/64x64/apps/application-x-cview.png" "/usr/share/icons/hicolor/64x64/apps/application-x-cviewall.png" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-cview.png" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-cviewall.png" /usr/share/mime/packages/cview-mimetype.xml /usr/share/mime/packages/cviewall-mimetype.xml /usr/share/applications/cview.desktop /usr/share/applications/cviewall.desktop
	do
		echo rm -f $x
		rm -f $x
	done
	TMPFILE=`mktemp`
	cat /usr/share/applications/defaults.list > $TMPFILE
	grep -v -e '^application/x-cview=cview\.desktop$' -e '^application/x-cviewall=cviewall\.desktop$' $TMPFILE > /usr/share/applications/defaults.list
	rm $TMPFILE
fi
update-mime-database /usr/share/mime
update-desktop-database
gtk-update-icon-cache /usr/share/icons/hicolor -f
