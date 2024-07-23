#/bin/bash

VERSION=1.6.0
RELEASE=node_exporter-${VERSION}.linux-amd64

apt update && apt upgrade -y
# install troubleshooting tools
apt install sudo nmon tmux tcpdump iputils-ping net-tools rsync tar pv -y

# install Docker + docker-compose
apt install ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-ce-cli containerd.io -y
systemctl start docker
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# install Prometheus node-exporter
_check_root () {
    if [ $(id -u) -ne 0 ]; then
        echo "Please run as root" >&2;
        exit 1;
    fi
}

_install_curl () {
    if [ -x "$(command -v curl)" ]; then
        return
    fi

    if [ -x "$(command -v apt-get)" ]; then
        apt-get update
        apt-get -y install curl
    elif [ -x "$(command -v yum)" ]; then
        yum -y install curl
    else
        echo "No known package manager found" >&2;
        exit 1;
    fi
}

_check_root
_install_curl

cd /tmp
curl -sSL https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/${RELEASE}.tar.gz | tar xz
#mkdir -p /opt/node_exporter
cp ${RELEASE}/node_exporter /usr/local/bin/
rm -rf /tmp/${RELEASE}
useradd --system --no-create-home --shell /usr/sbin/nologin prometheus

if [ -x "$(command -v systemctl)" ]; then
    cat << EOF > /etc/systemd/system/node-exporter.service
[Unit]
Description=Prometheus exporter for machine metrics

[Service]
Restart=always
User=prometheus
ExecStart=/usr/local/bin/node_exporter
ExecReload=/bin/kill -HUP $MAINPID
TimeoutStopSec=20s
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable node-exporter
    systemctl start node-exporter
    echo "The node-exporter service status is:"
    systemctl is-active node-exporter
    echo "End of prerequisites script."
fi
