#!/bin/bash

VERSION=1.6.0
RELEASE=node_exporter-${VERSION}.linux-amd64

INSTALL_NODE_EXPORTER=true

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --skip-node-exporter) INSTALL_NODE_EXPORTER=false ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

sudo apt update && sudo apt upgrade -y

# install Docker + docker-compose
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

# install troubleshooting tools
sudo apt install sudo apt-transport-https curl git nmon tmux tcpdump iputils-ping net-tools nano rsync tar pigz pv python3 python3-requests python3-pip docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Check if node-exporter installation is skipped
if [ "$INSTALL_NODE_EXPORTER" = true ]; then
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
ExecReload=/bin/kill -HUP \$MAINPID
TimeoutStopSec=20s
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF
    fi

    systemctl daemon-reload
    systemctl enable node-exporter
    systemctl start node-exporter
    echo "The node-exporter service status is:"
    systemctl is-active node-exporter
else
    echo "Skipping node-exporter installation."
fi

echo "End of prerequisites script."

