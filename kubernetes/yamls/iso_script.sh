cd /usr/local/k8_client/yamls
echo "now you are in k8_client/yamls"
sudo apt-add-repository universe
sudo apt-add-repository multiverse
#dpkg-divert --local --remote --add /sbin/initctl
echo ""
echo "
deb http://archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse"| sudo tee /etc/apt/source.list
echo "Installing Prerequesite packages......"

apt-get --fix-missing update -y
apt update
apt-get install openssh-server openssh-client vim git iputils-ping vim curl gcc tmux htop -y
apt-get install dialog -y
apt-get install apt-transport-https ca-certificates curl software-properties-common -y
apt install gnupg2 pass -y
apt-get install sshpass -y
apt-get install dialog jq net-tools ffmpeg -y
apt install ../apps/google-chrome-stable_current_amd64.deb -y
apt-get install pulseaudio -y
apt-get install -f -y
echo ""
echo "Installing Anydesk......."
echo""

wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list
apt update 
apt install anydesk -y
echo "Anydesk Install Successfully...!! ---> $?"
echo ""
add-apt-repository ppa:apt-fast/stable -y
apt-get update -y
apt-get install apt-fast -y
apt-get --fix-missing update -y
apt-get install -f -y
apt-get update -y
apt-get install xfce4 -y
apt-get install x2goserver x2goserver-xsession -y
echo "x2goserver install successfully... --> $?"
echo ""
echo "Installing Kubernetes and Docker..."

k8sversion=1.23.3-00
dockversion=5:20.10.12~3-0~ubuntu-$(lsb_release -cs)
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y

apt-get install docker-ce=5:20.10.12~3-0~ubuntu-bionic docker-ce-cli=5:20.10.12~3-0~ubuntu-bionic containerd.io -y
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -y
apt-get install kubeadm=$k8sversion kubectl=$k8sversion kubelet=$k8sversion -y

mkdir /etc/docker/
touch /etc/docker/daemon.json
echo '{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "storage-driver": "overlay2"
}' | tee /etc/docker/daemon.json
echo ""
echo "Setting up frpc..."
cp -r  ../frpc/frpc /usr/bin
cp -r ../frpc /etc
echo  "frpc setting setup successfully --> $?"

echo ""
echo "sshd_config file changes"
sed -i -e '/#Port/a Port 55200' /etc/ssh/sshd_config
sed -i -e '/prohibit-password/a PermitRootLogin no' /etc/ssh/sshd_config
sed -i -e 's/#PubkeyAuthentication/PubkeyAuthentication/g' /etc/ssh/sshd_config
sed -i -e 's/#AuthorizedKeysFile/AuthorizedKeysFile/g' /etc/ssh/sshd_config
echo "config file changes done successfull --> $?" 



