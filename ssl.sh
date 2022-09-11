#!/bin/bash

########################################################################################################################
# Find Us                                                                                                              #
# Author: Mehmet ÖĞMEN                                                                                                 #
# Web   : https://x-shell.codes/scripts/ssl                                                                          #
# Email : mailto:ssl.script@x-shell.codes                                                                            #
# GitHub: https://github.com/x-shell-codes/ssl                                                                       #
########################################################################################################################
# Contact The Developer:                                                                                               #
# https://www.mehmetogmen.com.tr - mailto:www@mehmetogmen.com.tr                                                       #
########################################################################################################################

########################################################################################################################
# Constants                                                                                                            #
########################################################################################################################
NORMAL_LINE=$(tput sgr0)
BLACK_LINE=$(tput setaf 0)
WHITE_LINE=$(tput setaf 7)
RED_LINE=$(tput setaf 1)
YELLOW_LINE=$(tput setaf 3)
GREEN_LINE=$(tput setaf 2)
BLUE_LINE=$(tput setaf 4)
POWDER_BLUE_LINE=$(tput setaf 153)
BRIGHT_LINE=$(tput bold)
REVERSE_LINE=$(tput smso)
UNDER_LINE=$(tput smul)

########################################################################################################################
# Version                                                                                                              #
########################################################################################################################
function Version() {
  echo "ssl version 1.0.0"
  echo
  echo "${BRIGHT_LINE}${UNDER_LINE}Find Us${NORMAL}"
  echo "${BRIGHT_LINE}Author${NORMAL}: Mehmet ÖĞMEN"
  echo "${BRIGHT_LINE}Web${NORMAL}   : https://x-shell.codes/scripts/ssl"
  echo "${BRIGHT_LINE}Email${NORMAL} : mailto:ssl.script@x-shell.codes"
  echo "${BRIGHT_LINE}GitHub${NORMAL}: https://github.com/x-shell-codes/ssl"
}

########################################################################################################################
# Help                                                                                                                 #
########################################################################################################################
function Help() {
  echo "A tool you can use to generate SSL certificates."
  echo
  echo "Options:"
  echo "-d | --domain      Domain name (example.com)"
  echo "-s | --subdomain   Subdomain name (api)"
  echo "-l | --isLocal     Is local env (auto-deject). Values: true, false"
  echo "-h | --help        Display this help."
  echo "-V | --version     Print software version and exit."
  echo
  echo "For more details see https://github.com/x-shell-codes/ssl."
}

########################################################################################################################
# Line Helper Functions                                                                                                #
########################################################################################################################
function ErrorLine() {
    echo "${RED_LINE}$1${NORMAL_LINE}"
}

function WarningLine() {
    echo "${YELLOW_LINE}$1${NORMAL_LINE}"
}

function SuccessLine() {
    echo "${GREEN_LINE}$1${NORMAL_LINE}"
}

function InfoLine() {
    echo "${BLUE_LINE}$1${NORMAL_LINE}"
}

########################################################################################################################
# Arguments Parsing                                                                                                    #
########################################################################################################################
isLocal=false
if [ -d "/vagrant" ]; then
  isLocal=true
fi

for i in "$@"; do
  case $i in
  -d=* | --domain=*)
    domain="${i#*=}"

    if [ -z "$domain" ]; then
      ErrorLine "Domain name is empty."
      exit
    fi

    shift
    ;;
  -s=* | --subdomain=*)
    subdomain="${i#*=}"

    if [ -z "$subdomain" ]; then
      ErrorLine "Subdomain name is empty."
      exit
    fi

    shift
    ;;
  -l=* | --isLocal=*)
    isLocal="${i#*=}"

    if [ "$isLocal" != "true" ] && [ "$isLocal" != "false" ]; then
      ErrorLine "Is local value is invalid."
      Help
      exit
    fi

    shift
    ;;
  -h | --help)
    Help
    exit
    ;;
  -V | --version)
    Version
    exit
    ;;
  -* | --*)
    ErrorLine "Unexpected option: $1"
    echo
    echo "Help:"
    Help
    exit
    ;;
  esac
done

########################################################################################################################
# CheckRootUser Function                                                                                               #
########################################################################################################################
function CheckRootUser() {
  if [ "$(whoami)" != root ]; then
    ErrorLine "You need to run the script as user root or add sudo before command."
    exit 1
  fi
}

########################################################################################################################
# NginxInstallCheck Function                                                                                           #
########################################################################################################################
function NginxInstallCheck() {
  REQUIRED_PKG="nginx"
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG | grep "install ok installed")
  if [ "" = "$PKG_OK" ]; then
    ErrorLine "Nginx is not installed."
    exit
  fi
}

########################################################################################################################
# SelfSignedCertificateInstallation Function                                                                           #
########################################################################################################################
function SelfSignedCertificateInstallation() {
  domain=$1
  subdomain=$2

  if [ ! -d "/etc/nginx/ssl" ]; then
    mkdir /etc/nginx/ssl
  fi

  if [ ! -d "/etc/nginx/ssl/$domain" ]; then
    mkdir "/etc/nginx/ssl/$domain"
  fi

  InfoLine "/etc/nginx/ssl/$domain/$subdomain.key checking is the file exists..."
  if [ ! -f "/etc/nginx/ssl/$domain/$subdomain.key" ]; then
    InfoLine "/etc/nginx/ssl/$domain/$subdomain.key is creating..."
    openssl genrsa -out "/etc/nginx/ssl/$domain/$subdomain.key" 2048
    SuccessLine "/etc/nginx/ssl/$domain/$subdomain.key is created."
  else
    WarningLine "Certificate key file already exists."
  fi

  echo

  InfoLine "/etc/nginx/ssl/$domain/$subdomain.cert checking is the file exists..."
  if [ ! -f "/etc/nginx/ssl/$domain/$subdomain.cert" ]; then
    InfoLine "/etc/nginx/ssl/$domain/$subdomain.cert is creating..."
    openssl req -new -x509 -key "/etc/nginx/ssl/$domain/$subdomain.key" -out "/etc/nginx/ssl/$domain/$subdomain.cert" -days 3650 -subj /CN="$subdomain.$domain"
    SuccessLine "/etc/nginx/ssl/$domain/$subdomain.cert is created."
  else
    WarningLine "Certificate file already exists."
  fi
}

########################################################################################################################
# CertBotCertificateInstallation Function                                                                              #
########################################################################################################################
function CertBotCertificateInstallation() {
  domain=$1
  subdomain=$2

  # @todo: Check if certbot is installed.
}

########################################################################################################################
# Main Program                                                                                                         #
########################################################################################################################
echo "${POWDER_BLUE_LINE}${BRIGHT_LINE}${REVERSE_LINE}   SSL INSTALLATION   ${NORMAL_LINE}"

CheckRootUser

export DEBIAN_FRONTEND=noninteractive

NginxInstallCheck

if [ -z "$domain" ]; then
  ErrorLine "Domain name is empty."
  exit
elif [ -z "$subdomain" ]; then
  ErrorLine "Subdomain name is empty."
  exit
fi

echo

if [ "$isLocal" == "true" ]; then
  SelfSignedCertificateInstallation $domain $subdomain
else
  CertBotCertificateInstallation $domain $subdomain
fi
