#!/bin/bash
# CentOS 8 服务器一键初始化 + 安全加固脚本
# 功能：关闭SELinux、更换阿里源、基础环境、安全配置、时间同步、防火墙

echo "====== 开始服务器初始化配置 ======"

# 1. 关闭 SELinux
setenforce 0
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
echo "1. SELinux 已关闭"

# 2. 替换官方Vault源
cd /etc/yum.repos.d
mkdir -p backup
mv *.repo backup/

cat > CentOS-Base.repo << EOF
[BaseOS]
name=CentOS-\$releasever - Base
baseurl=https://vault.centos.org/centos/\$releasever/BaseOS/\$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[AppStream]
name=CentOS-\$releasever - AppStream
baseurl=https://vault.centos.org/centos/\$releasever/AppStream/\$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[extras]
name=CentOS-\$releasever - Extras
baseurl=https://vault.centos.org/centos/\$releasever/extras/\$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF

yum clean all && yum makecache

# 3. 安装运维必备工具
yum install -y wget net-tools vim tree git python3 chrony
echo "3. 基础工具安装完成"

# 4. 配置时区 + 时间同步
timedatectl set-timezone Asia/Shanghai
systemctl start chronyd
systemctl enable chronyd
echo "4. 时区与时间同步配置完成"

# 5. 防火墙放行常用端口
firewall-cmd --permanent --add-service=ssh 2>/dev/null
firewall-cmd --permanent --add-port=80/tcp 2>/dev/null
firewall-cmd --permanent --add-port=443/tcp 2>/dev/null
firewall-cmd --reload 2>/dev/null
echo "5. 防火墙规则配置完成"

# 6. 新建普通运维用户，禁止root直接业务操作
useradd opsuser
echo "Ops@123456" | passwd --stdin opsuser
echo 'opsuser  ALL=(ALL)  NOPASSWD: ALL' > /etc/sudoers.d/opsuser
chmod 0440 /etc/sudoers.d/opsuser
echo "6. 运维普通账号创建完成"

echo "====== 全部配置完成，建议重启服务器生效 ====="
