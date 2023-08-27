#!/bin/bash
unlink $0
#常规变量设置
#fonts color
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

#notification information
Info="${Green}[Info]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[Error]${Font}"
Notification="${Yellow}[Notification]${Font}"


# check root
# shellcheck disable=SC2046
[ $(id -u) != "0" ] && { echo "错误: 您必须以root用户运行此脚本"; exit 1; }

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "${Red}未检测到系统版本，请联系脚本作者！${Font}\n" && exit 1
fi

if [ "$(getconf WORD_BIT)" != '32' ] && [ "$(getconf LONG_BIT)" != '64' ] ; then
    echo "本软件不支持 32 位系统(x86)，请使用 64 位系统(x86_64)，如果检测有误，请联系作者"
    exit 2
fi

os_version=""

# os version
if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"centos" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        # shellcheck disable=SC2154
        echo -e "${red}请使用 CentOS 7 或更高版本的系统！${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}请使用 Ubuntu 16 或更高版本的系统！${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}请使用 Debian 8 或更高版本的系统！${plain}\n" && exit 1
    fi
fi

install_base() {
    if [[ x"${release}" == x"centos" ]]; then
      yum install epel-release -y
      yum install wget curl tar crontabs socat ntpdate htpdate -y
      systemctl stop firewalld.service
      systemctl disable firewalld.service
    else
      apt install wget curl tar cron socat ntpdate htpdate -y
		  ufw stop && ufw disable >/dev/null 2>&1
    fi
}

DOCKER_INSTALL() {
    docker_exists=$(docker version 2>/dev/null)
    if [[ ${docker_exists} == "" ]]; then
        echo -e "${Green} [✓] 正在安装docker ${Font}"
        curl -fsSL get.docker.com | bash
        # shellcheck disable=SC2181
        if [ $? -ne 0 ]; then
          echo -e "${Green} [×] 资源下载失败，请重试。 ${Font}" && exit 1
        fi
    fi

    docker_compose_exists=$(docker-compose version 2>/dev/null)
    if [[ ${docker_compose_exists} == "" ]]; then
        echo -e "${Green} [✓] 正在安装docker-compose ${Font}"
        # shellcheck disable=SC2046
        curl -L --fail https://ghproxy.com/https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose >/dev/null 2>&1
        # shellcheck disable=SC2181
        if [ $? -ne 0 ]; then
          echo -e "${Green} [×] 资源下载失败，请重试。 ${Font}" && exit 1
        fi
        chmod +x /usr/local/bin/docker-compose && \
	      ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi
}

SYNC_TIME() {
     echo -e "${Green} [✓] 同步时间中 ${Font}"
     timedatectl set-timezone Asia/Shanghai
     ntpdate pool.ntp.org || htpdate -s www.baidu.com >/dev/null 2>&1
     hwclock -w
 }

# shellcheck disable=SC2120
DOCKER_UP() {
    chmod +x /etc/elmWeb
    cd /etc/elmWeb || exit

    if [ ! -f "/etc/elmWeb/docker-compose.yml" ]; then
        wget https://ghproxy.com/https://raw.githubusercontent.com/zelang/elmWeb-docker/main/docker-compose.yml -O /etc/elmWeb/docker-compose.yml >/dev/null 2>&1
        # shellcheck disable=SC2181
        if [ $? -ne 0 ]; then
          echo -e "${Green} [×] 资源下载失败，请重试。 ${Font}" && exit 1
        fi
    fi

    docker-compose pull
    docker-compose up -d --force-recreate
}

main(){
  clear
  echo -e "欢迎使用ElmWeb Docker一键部署脚本"
  # shellcheck disable=SC2162
  read -p "输入Y/y确认安装 跳过安装请直接回车:  " CONFIRM
  CONFIRM=${CONFIRM:-"N"}
  if [[ ${CONFIRM} == "Y" || ${CONFIRM} == "y" ]];then
    install_base
    if [ ! -d "/etc/elmWeb" ]; then
      mkdir /etc/elmWeb
    fi
    wget https://ghproxy.com/https://raw.githubusercontent.com/zelang/elmWeb-docker/main/config.ini -O /etc/elmWeb/config.ini >/dev/null 2>&1
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
      echo -e "${Green} [×] 资源下载失败，请重试。 ${Font}" && exit 1
    fi
    # shellcheck disable=SC2162
    read -p "输入您购买的授权码(必须):  " AUTH_CODE
    AUTH_CODE=${AUTH_CODE:-""}
    # shellcheck disable=SC1073
    # shellcheck disable=SC1009
    if [[ ${AUTH_CODE} == "" ]];then
      echo -e "${Green} [×] 授权码是必须输入项，请重试。 ${Font}" && exit 1
    else
      random_string=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
      sed -i '/auth_code = /c \auth_code = '"${AUTH_CODE}"'' /etc/elmWeb/config.ini
      sed -i '/secret = /c \secret = '"${random_string}"'' /etc/elmWeb/config.ini
    fi
  	SYNC_TIME
  	DOCKER_INSTALL
  	DOCKER_UP
  fi
  exit 0
}
# Start Install
main