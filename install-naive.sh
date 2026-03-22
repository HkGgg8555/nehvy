set -e

echo "===> 安装依赖"
apt update -y >/dev/null 2>&1
apt install -y wget git curl >/dev/null 2>&1

echo "===> 安装 Go"
cd /tmp
wget -q https://go.dev/dl/go1.22.5.linux-amd64.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin
grep -q "/usr/local/go/bin" /root/.bashrc || echo 'export PATH=$PATH:/usr/local/go/bin:/root/go/bin' >> /root/.bashrc

echo "===> 安装 xcaddy"
/usr/local/go/bin/go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
export PATH=$PATH:/root/go/bin

echo "===> 编译 Caddy 2.11.2 + Naive"
/root/go/bin/xcaddy build v2.11.2 \
  --with github.com/caddyserver/forwardproxy@latest=github.com/klzgrad/forwardproxy@latest

echo "===> 备份旧版本"
if [ -f /usr/local/bin/caddy-naive ]; then
  mv /usr/local/bin/caddy-naive /usr/local/bin/caddy-naive.bak
fi

echo "===> 安装新二进制"
mv caddy /usr/local/bin/caddy-naive
chmod +x /usr/local/bin/caddy-naive

echo "===> 完成，验证版本"
/usr/local/bin/caddy-naive version
/usr/local/bin/caddy-naive build-info | grep forward

echo "===> 如果你用 systemd，执行：systemctl restart caddy"
