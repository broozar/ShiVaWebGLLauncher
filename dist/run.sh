#!/bin/sh

# ShiVa WebGL/HTML5 Desktop Distributon Kit
# version 2020-04-25
# Felix Caffier
# MIT license for launcher files, included games may be licensed differently


# ------------------------------------ setup

# master variables
SRV_RUNNING=0
SRV_PORT=54321
SRV_PID=$!
BROWSER_FOUND=0
BROWSER_PID=0

# pretty colors!
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# use script location as base dir
cd $(dirname $0)


# ------------------------------------ checks

c_root () {
	MY_ID=$(id -u)
	if [ "$MY_ID" -eq 0 ]; then
		printf "[ ${RED}ERROR${NC} ]  This script must not be run as ${CYAN}root user${NC}.\n"
		exit 1
	fi
	printf "[ ${GREEN}INFO${NC} ]  Not running as root\n"
}
c_root

c_arch () {
	MY_ARCH=$(uname -m)
	printf "[ ${GREEN}INFO${NC} ]  Processor architecture: $MY_ARCH \n"
}
c_arch

c_network () {
	if nc -zw1 8.8.8.8 443 > /dev/null 2>&1 ; then
		printf "[ ${GREEN}INFO${NC} ]  Internet connection detected\n"
	else
		printf "[ ${YELLOW}NOTE${NC} ]  Could not verify internet connection\n"
	fi
}
c_network

# ------------------------------------ scan ports for a free one
# TODO

# ------------------------------------ figure out which server to use

srv_busybox () {
	if [ $SRV_RUNNING -ne 0 ] ; then
		return 0
	fi
	command -v busybox > /dev/null
	if [ $? -eq 0 ] ; then
		busybox httpd -f -p $SRV_PORT & SRV_PID=$!
		printf "[ ${GREEN}INFO${NC} ]  Running a ${CYAN}Busybox${NC} server \n"
		SRV_RUNNING=1
	fi
}

srv_python () {
	if [ $SRV_RUNNING -ne 0 ] ; then
		return 0
	fi
	command -v python > /dev/null
	if [ $? -eq 0 ] ; then
		# detect python 2 or 3
		PYV=$(python -c 'import platform; print(platform.python_version())' | cut -c1)
		if [ $PYV -eq 2 ] ; then
			python -m SimpleHTTPServer $SRV_PORT & SRV_PID=$!
			printf "[ ${GREEN}INFO${NC} ]  Running a ${CYAN}Python 2${NC} server \n"
			SRV_RUNNING=1
		elif [ $PYV -eq 3 ] ; then
			python -m http.server $SRV_PORT & SRV_PID=$!
			printf "[ ${GREEN}INFO${NC} ]  Running a ${CYAN}Python 3${NC} server \n"
			SRV_RUNNING=1
		else
			printf "[ ${YELLOW}INFO${NC} ]  Python version not detected.\n"
		fi	
	fi
}

srv_php () {
	if [ $SRV_RUNNING -ne 0 ] ; then
		return 0
	fi
	command -v php > /dev/null
	if [ $? -eq 0 ] ; then
		php -S 127.0.0.1:$SRV_PORT
		printf "[ ${GREEN}INFO${NC} ]  Running a ${CYAN}PHP${NC} server \n"
		SRV_RUNNING=1
	fi
}

start_srv () {
	srv_busybox
	srv_python
	srv_php
	sleep 1
}
start_srv

# ------------------------------------ figure out which browser to use

web_gc () {
	if [ $BROWSER_FOUND -ne 0 ] ; then
		return 0
	fi
	command -v chrome > /dev/null
	if [ $? -eq 0 ] ; then
		printf "[ ${GREEN}INFO${NC} ]  Running a ${CYAN}Google Chrome${NC} app\n"
		chrome --app="data:text/html,<html><body><script>var wW=800;var wH=600;var xPos=(screen.width/2)-(wW/2);var yPos=(screen.height/2)-(wH/2);window.resizeTo(wW,wH);window.moveTo(xPos,yPos);window.location='http://127.0.0.1:$SRV_PORT/launcher';document.title='ShiVa WebGL Launcher';</script></body></html>" & BROWSER_PID=$!
		BROWSER_FOUND=1
	fi
}

web_ium () {
	if [ $BROWSER_FOUND -ne 0 ] ; then
		return 0
	fi
	command -v chromium > /dev/null
	if [ $? -eq 0 ] ; then
		printf "[ ${GREEN}INFO${NC} ]  Running a ${CYAN}Chromium${NC} app\n"
		chromium --app="data:text/html,<html><body><script>var wW=800;var wH=600;var xPos=(screen.width/2)-(wW/2);var yPos=(screen.height/2)-(wH/2);window.resizeTo(wW,wH);window.moveTo(xPos,yPos);window.location='http://127.0.0.1:$SRV_PORT/launcher';document.title='ShiVa WebGL Launcher';</script></body></html>" & BROWSER_PID=$!
		BROWSER_FOUND=1
	fi
}

web_ff () {
	if [ $BROWSER_FOUND -ne 0 ] ; then
		return 0
	fi
	command -v firefox > /dev/null
	if [ $? -eq 0 ] ; then
		# get FF version - kiosk mode reuqires FF >= 71
		FFV=$(firefox -v | awk '{split($0,a); print a[3],a[2],a[1]}' | awk '{split($0,b,"."); print b[1]}')
		if [ $FFV -gt 70 ] ; then
			printf "[ ${GREEN}INFO${NC} ]  Running a ${CYAN}Firefox${NC} kiosk\n"
			firefox -kiosk http://localhost:$SRV_PORT/launcher & BROWSER_PID=$!
			BROWSER_FOUND=1
		fi
	fi
}

if [ $SRV_RUNNING -ne 0 ] ; then
	web_gc
	web_ium
	web_ff
fi

web_unsupported () {
	if [ $BROWSER_FOUND -eq 0 ] ; then
		xdg-open ./launcher/unsupported.html
		return 1
	fi
}
web_unsupported

# ------------------------------------ wait

echo $BROWSER_PID

while [ true ] ; do
	sleep 5
	kill -0 $BROWSER_PID > /dev/null
	if [ $? -ne 0 ] ; then
		break
	fi
done

# ------------------------------------ cleanup

if [ $SRV_RUNNING -ne 0 ] ; then
	kill $SRV_PID
fi

printf "[ ${GREEN}INFO${NC} ]  Exiting\n"
