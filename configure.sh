sudo cat <<EOT > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 9.9.9.9
EOT
echo "DNS Configured"
cat resolv.conf
echo "Configuring golang"
sudo tar -C /usr/local -xzf $HOME/software/go1.13.1.linux-amd64.tar.gz
echo "Golang configured successfully"
go version
mkdir $HOME/cloudprobe
#yoto
filename=$HOME/.profile
if [ ! -f $filename ]
then
    touch $filename
fi
cmd_list=("export GOROOT=/usr/local/go" "export GOPATH=\$HOME/cloudprobe" "export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH")
for cmd in "${cmd_list[@]}"; do
    grep -qxF "$cmd" profile || echo "$cmd" >> profile
done
echo "Added path to profile"
echo "Downloading cloudprobe"
go get -v github.com/google/cloudprober
GOBIN=$GOPATH/bin go install $GOPATH/src/github.com/google/cloudprober/cmd/cloudprober.go
echo "Cloudprober installed"
echo "Enabling ping" 
sudo sysctl -w net.ipv4.ping_group_range="0 5000"
echo "Creating default probe config"
cat > /tmp/cloudprober.cfg <<EOF
probe {
  name: "google"
  type: PING
  targets {
    host_names: "www.google.com"
  }
  interval_msec: 5000  # 5s
  timeout_msec: 1000   # 1s
}
probe {
  name: "sg1.sdcore"
  type: PING
  targets {
    host_names: "192.168.99.2"
  }
  interval_msec: 5000  # 5s
  timeout_msec: 1000   # 1s
}

probe {
  name: "sg2.sdcore"
  type: PING
  targets {
    host_names: "192.168.100.2"
  }
  interval_msec: 5000  # 5s
  timeout_msec: 1000   # 1s
}
probe {
  name: "hk1.sdcore"
  type: PING
  targets {
    host_names: "192.168.30.2"
  }
  interval_msec: 5000  # 5s
  timeout_msec: 1000   # 1s
}
probe {
  name: "jp1.sdcore"
  type: PING
  targets {
    host_names: "192.168.101.2"
  }
  interval_msec: 5000  # 5s
  timeout_msec: 1000   # 1s
}
EOF
echo "Added default probe config to /tmp/cloudprober.cfg"
echo "Running probe"
$GOPATH/bin/cloudprober --config_file /tmp/cloudprober.cfg
echo "Probe running now"
