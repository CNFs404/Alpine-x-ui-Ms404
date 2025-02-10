#!/bin/bash

# 定义颜色变量
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# 输出颜色函数
red(){ echo -e "\033[31m\033[01m$1\033[0m";}
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
yellow(){ echo -e "\033[33m\033[01m$1\033[0m";}
blue(){ echo -e "\033[36m\033[01m$1\033[0m";}
white(){ echo -e "\033[37m\033[01m$1\033[0m";}

# 检查是否为 root 用户
[[ $EUID -ne 0 ]] && echo -e "${red}错误：${plain} 必须使用root用户运行此脚本！\n" && exit 1

# 检查系统
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
elif cat /etc/system-release-cpe | grep -Eqi "amazon_linux"; then
    release="amazon_linux"
else
    echo -e "${red}未检测到系统版本，请联系脚本作者！${plain}\n" && exit 1
fi

# 安装必要的依赖
install_base() {
    if [[ x"${release}" == x"centos" ]]; then
        yum install epel-release -y && yum install wget curl tar -y
    else
        apt update && apt install wget curl tar -y
    fi
}

# 安装 x-ui
install_x_ui() {
    systemctl stop x-ui
    cd /usr/local/

    wget -N --no-check-certificate -O /usr/local/x-ui-linux-amd64.tar.gz https://github.com/MHSanaei/3x-ui/releases/download/v1.7.9/x-ui-linux-amd64.tar.gz
    if [[ $? -ne 0 ]]; then
        echo -e "${red}下载 x-ui 失败，请确保你的服务器能够下载 Github 的文件${plain}"
        exit 1
    fi

    if [[ -e /usr/local/x-ui/ ]]; then
        rm /usr/local/x-ui/ -rf
    fi

    tar zxvf x-ui-linux-amd64.tar.gz
    rm x-ui-linux-amd64.tar.gz -f
    cd x-ui
    chmod +x x-ui bin/xray-linux-amd64
    cp -f x-ui.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable x-ui
    systemctl start x-ui
}

# 设置端口、用户名和密码
configure_x_ui() {
    local port=8080
    local username="root"
    local password="20240513Ccye"

    echo "正在设置 x-ui 端口为 $port..."
    x-ui setting -port $port
    if [ $? -ne 0 ]; then
        echo -e "${red}端口设置失败，请检查 x-ui 是否已正确安装并运行。${plain}"
        exit 1
    fi

    echo "正在设置 x-ui 用户名为 $username，密码为 $password..."
    x-ui setting -username $username -password $password
    if [ $? -ne 0 ]; then
        echo -e "${red}用户名和密码设置失败，请检查 x-ui 是否已正确安装并运行。${plain}"
        exit 1
    fi

    echo "重启 x-ui 服务以应用更改..."
    systemctl restart x-ui
    if [ $? -ne 0 ]; then
        echo -e "${red}重启 x-ui 服务失败，请检查 x-ui 是否已正确安装并运行。${plain}"
        exit 1
    fi

    echo -e "${green}x-ui 配置完成！${plain}"
}

# 主函数
main() {
    echo -e "${green}开始安装 x-ui 必要依赖${plain}"
    install_base

    echo -e "${green}开始安装 x-ui 核心组件${plain}"
    install_x_ui

    echo -e "${green}开始配置 x-ui${plain}"
    configure_x_ui
}

# 执行主函数
main
