#!/bin/sh -e
VERSION=1.6.0
RELEASE=node_exporter-${VERSION}.linux-amd64

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
    systemctl status node-exporter
fi
