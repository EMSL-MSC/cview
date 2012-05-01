#!/bin/sh

# Author: Brock Erwin
# Install/Uninstall cview file associations

usage() {
	echo Usage: $0 -i
	echo '       This installs cview associations'
	echo '       If you run this as root, then I will make associations for all users'
	echo '       If you run this as a regular user, I will only make associations for you'
	echo Usage: $0 -u
	echo '       This uninstalls cview associations'
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
if [ `whoami` = "root" ]; then
	EXTRA_ARGS="--mode system"
else
	echo "Installing for `whoami`"
	EXTRA_ARGS=""
fi

echo "Performing an $MODE"

set -x

xdg-mime $MODE $EXTRA_ARGS cview-filetype.xml
xdg-mime $MODE $EXTRA_ARGS cviewall-filetype.xml
xdg-icon-resource $MODE $EXTRA_ARGS --size 64 icon64.png application-x-cview
xdg-icon-resource $MODE $EXTRA_ARGS --size 64 icon64.png application-x-cviewall
if [ "x$EXTRA_ARGS" = "x" ]; then
	if [ "$MODE" = "install" ]; then
		# The man page says do NOT run these commands as root
		xdg-mime default cview.desktop application/x-cview
		xdg-mime default cviewall.desktop application/x-cviewall
	else
		echo 'Unfortunately, we do not have a good way to remove user defined defaults....'
	fi
else
	if [ "$MODE" = "install" ]; then
		TMPFILE=`mktemp`
		cat /usr/share/applications/defaults.list > $TMPFILE
		grep -q 'application/x-cview=cview.desktop' || echo 'application/x-cview=cview.desktop' >> $TMPFILE
		grep -q 'application/x-cviewall=cviewall.desktop' || echo 'application/x-cviewall=cviewall.desktop' >> $TMPFILE
		sort $TMPFILE > /usr/share/applications/defaults.list
		rm $TMPFILE
	else
		TMPFILE=`mktemp`
		cat /usr/share/applications/defaults.list > $TMPFILE
		grep -v -e '^application/x-cview=cview\.desktop$' -e '^application/x-cviewall=cviewall\.desktop$' $TMPFILE > /usr/share/applications/defaults.list
		rm $TMPFILE
	fi
fi
