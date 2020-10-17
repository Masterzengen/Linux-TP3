setenforce 0
sed -i 's/enforcing/permissive/' /etc/selinux/config

sudo yum update -y
sudo yum install -y epel-release
sudo yum install -y nginx
sudo yum install -y vim

systemctl enable --now firewalld

