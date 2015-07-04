#!/bin/bash
# Game Server Repo
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
# Version: 040715
# Development use only!
# Description: Creates and updates a repository of all game server content used by LGSM.

fn_steamlogin(){
# Steam login
steamuser="username"
steampass="password"
}

fn_repo_update(){
serverdir="${repodir}/${servername}"
filesdir="${serverdir}/serverfiles"

#House Keeping

## Remove functions directory
	if [ -d ${serverdir}/functions ]; then
		echo -e "\e[0;36mremoving functions dir...\e[0;39m"
		echo "${serverdir}/functions"
		rm -rfv ${serverdir}/functions
	fi

## Clear any log directorys/files
	if [ -d ${serverdir}/log ]; then
		echo -e "\e[0;36mremoving log directorys...\e[0;39m"
		echo "${serverdir}/log"
		mkdir -pv ${serverdir}/log/script
		mkdir -pv ${serverdir}/log/console
		rm -rfv ${serverdir}/log/script/*
		rm -rfv ${serverdir}/log/console/*
		rm -rfv ${serverdir}/log/server
	fi

## Delete any existing Glibc fix files
	# ARMA 3
	if [ "${servername}" == "arma3server" ]; then
		rm "${filesdir}/libstdc++.so.6"
	# Blade Symphony
	elif [ "${servername}" == "bsserver" ]; then
		rm "${filesdir}/libstdc++.so.6"
	# Double Action: Boogaloo
	elif [ "${servername}" == "dabserver" ]; then
		rm "${filesdir}/bin/libm.so.6"
	# Fistful of Frags
	elif [ "${servername}" == "fofserver" ]; then
		rm "${filesdir}/libm.so.6"
	# Garrys's Mod
	elif [ "${servername}" == "gmodserver" ]; then
		rm "${filesdir}/bin/libc.so.6"
		rm "${filesdir}/bin/libm.so.6"
		rm "${filesdir}/bin/libpthread.so.0"
		rm "${filesdir}/libstdc++.so.6"
	# Insurgency
	elif [ "${servername}" == "insserver" ]; then
		rm "${filesdir}/bin/libc.so.6"
		rm "${filesdir}/bin/librt.so.1"
		rm "${filesdir}/bin/libpthread.so.0"
	# Just Cause 2
	elif [ "${servername}" == "jc2server" ]; then
		rm "${filesdir}/libstdc++.so.6"
	# Natural Selection 2
	elif [ "${servername}" == "ns2server" ]; then
		rm "${filesdir}/libm.so.6"
		rm "${filesdir}/libstdc++.so.6"
	# No More Room in Hell
	elif [ "${servername}" == "nmrihserver" ]; then
		rm "${filesdir}/libm.so.6"
		rm "${filesdir}/libstdc++.so.6"
	# Serious Sam 3: BFE
	elif [ "${servername}" == "ss3server" ]; then
		rm "${filesdir}/libstdc++.so.6"
	fi

# Login Select
if [ "${login}" == "user" ];then
	fn_steamlogin
elif [ "${login}" == "anonymous" ];then
# Steam login
	steamuser="anonymous"
	steampass=""
fi

# Download latest script file
mkdir -pv "${serverdir}"
mkdir -pv "${filesdir}"
cd ${serverdir}
if [ -f ${serverdir}/log ]; then
	rm ${serverdir}/${servername}
fi

echo -e "\e[0;36mdownloading latest ${servername}...\e[0;39m\c"
wget -N /dev/null http://gameservermanagers.com/dl/${servername} 2>&1 | grep -F HTTP | grep -v "Moved Permanently" |cut -c45-
chmod +x ${serverdir}/${servername}

# Download gsquery if supported
# Gets engine details from the script
engine=$(grep engine= ${servername}|sed 's/\engine=//g'|tr -d '=\";')
if [ "${engine}" == "avalanche" ]||[ "${engine}" == "goldsource" ]||[ "${engine}" == "realvirtuality" ]||[ "${engine}" == "source" ]||[ "${engine}" == "spark" ]||[ "${engine}" == "unity3d" ]||[ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]||[ "${engine}" == "unreal2" ]; then
	echo -e "\e[0;36mdownloading latest gsquery.py...\e[0;39m\c"
	if [ -f gsquery.py ];then
		rm gsquery.py
	fi
	wget -N /dev/null http://gameservermanagers.com/dl/gsquery.py 2>&1 | grep -F HTTP | grep -v "Moved Permanently" |cut -c45-
	chmod +x gsquery.py
else
	if [ -f gsquery.py ];then
		rm gsquery.py
	fi
fi

# Download server files
if [ "${appid}" != "nonsteam" ]; then
	# Check SteamCMD is installed
	echo -e "\e[0;36mchecking SteamCMD installed for ${servername}...\e[0;39m"
	cd "${serverdir}"
	mkdir -pv "steamcmd"
	cd "steamcmd"
	if [ ! -f steamcmd.sh ]; then
		wget -nv -N http://media.steampowered.com/client/steamcmd_linux.tar.gz
		tar --verbose -zxf steamcmd_linux.tar.gz
		rm -v steamcmd_linux.tar.gz
		chmod +x steamcmd.sh
	else
		echo "Steam already installed!"
	fi

	# Download updates via SteamCMD
	echo ""
	echo -e "\e[0;36mchecking SteamCMD for ${servername} updates...\e[0;39m"
	mkdir -pv "${filesdir}"
	cd "${serverdir}/steamcmd"
	./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_update "${appid}" +quit
	echo -e "\e[0;36mchecking SteamCMD for ${servername} updates...\e[0;39m"
fi
}

# Directories
rootdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repodir="${rootdir}/repository"

#Header
echo "================================="
echo "Linux Game Server Manager"
echo "Server Content Repository Updater"
echo "by Daniel Gibbs"
echo "http://gameservermanagers.com"
echo "For Development Only"
echo "================================="

#Create repo directory
if [ ! -d ${repodir} ]; then
	mkdir -pv ${repodir}
	sleep 1
fi

# Loop though list of servers
INPUT=csv/gameserver-repo-lgsm-list.csv
OLDIFS=$IFS
IFS=,
counter=1
[ ! -f ${INPUT} ] && { echo "${INPUT} file not found"; exit 99; }
while read gamename appid servername login
do
	test ${counter} -eq 1 && ((counter=counter+1)) && continue
	echo ""
	echo "Updating ${servername}"
	echo "================================="
	echo ""
	echo "Gamename: ${gamename}"
	echo "Appid: ${appid}"
	echo "Servername: ${servername}"
	echo "Login: ${login}"
	echo ""
	fn_repo_update
done < $INPUT
IFS=$OLDIFS
