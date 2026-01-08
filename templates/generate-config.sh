#!/bin/bash

# sing-box 配置生成助手
# 版本: 1.0
# 适用于: sing-box 1.12.15+

set -e

echo "=========================================="
echo "  sing-box 配置生成助手"
echo "=========================================="
echo ""

# 检查 sing-box 是否安装
if ! command -v sing-box &> /dev/null; then
    echo "错误: 未找到 sing-box 命令"
    echo "请先安装 sing-box: https://sing-box.sagernet.org/installation/"
    exit 1
fi

# 显示 sing-box 版本
echo "检测到 sing-box 版本:"
sing-box version
echo ""

# 生成密钥函数
generate_password() {
    sing-box generate rand --base64 16 2>/dev/null
}

echo "正在生成配置所需的密钥..."
echo ""

# 生成密钥
SHADOWSOCKS_PASSWORD=$(generate_password)
SHADOWTLS_PASSWORD=$(generate_password)
SHADOWTLS_USER_PASSWORD=$(generate_password)

echo "✓ 已生成密钥:"
echo "  Shadowsocks 密码: $SHADOWSOCKS_PASSWORD"
echo "  ShadowTLS 密码: $SHADOWTLS_PASSWORD"
echo "  ShadowTLS 用户密码: $SHADOWTLS_USER_PASSWORD"
echo ""

# 询问用户输入
read -p "请输入服务器 IP 或域名: " SERVER_ADDRESS
read -p "请输入服务器监听端口 (默认 443): " SERVER_PORT
SERVER_PORT=${SERVER_PORT:-443}

read -p "请输入握手服务器域名 (默认 www.bing.com): " HANDSHAKE_SERVER
HANDSHAKE_SERVER=${HANDSHAKE_SERVER:-www.bing.com}

echo ""
echo "正在生成配置文件..."

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 生成服务端配置
cat > "${SCRIPT_DIR}/server-config.json" <<EOF
{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "local-dns",
        "address": "223.5.5.5",
        "detour": "direct"
      }
    ]
  },
  "inbounds": [
    {
      "type": "shadowtls",
      "tag": "shadowtls-in",
      "listen": "::",
      "listen_port": ${SERVER_PORT},
      "version": 3,
      "password": "${SHADOWTLS_PASSWORD}",
      "users": [
        {
          "name": "user1",
          "password": "${SHADOWTLS_USER_PASSWORD}"
        }
      ],
      "handshake": {
        "server": "${HANDSHAKE_SERVER}",
        "server_port": 443
      },
      "strict_mode": true,
      "detour": "shadowsocks-in"
    },
    {
      "type": "shadowsocks",
      "tag": "shadowsocks-in",
      "listen": "127.0.0.1",
      "listen_port": 8388,
      "method": "2022-blake3-aes-128-gcm",
      "password": "${SHADOWSOCKS_PASSWORD}",
      "multiplex": {
        "enabled": true,
        "padding": true
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ],
  "route": {
    "rules": [
      {
        "protocol": "dns",
        "outbound": "direct"
      }
    ],
    "final": "direct"
  }
}
EOF

# 生成客户端配置
cat > "${SCRIPT_DIR}/client-config.json" <<EOF
{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "remote-dns",
        "address": "tls://8.8.8.8",
        "detour": "proxy"
      },
      {
        "tag": "local-dns",
        "address": "223.5.5.5",
        "detour": "direct"
      },
      {
        "tag": "block-dns",
        "address": "rcode://success"
      }
    ],
    "rules": [
      {
        "outbound": "any",
        "server": "local-dns"
      },
      {
        "domain_suffix": [".cn"],
        "server": "local-dns"
      },
      {
        "rule_set": "geosite-cn",
        "server": "local-dns"
      }
    ],
    "final": "remote-dns",
    "independent_cache": true,
    "cache_capacity": 10000
  },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "interface_name": "sing-tun",
      "inet4_address": "172.19.0.1/30",
      "inet6_address": "fdfe:dcba:9876::1/126",
      "mtu": 9000,
      "auto_route": true,
      "strict_route": true,
      "stack": "mixed",
      "sniff": true,
      "sniff_override_destination": false
    }
  ],
  "outbounds": [
    {
      "type": "shadowsocks",
      "tag": "proxy",
      "server": "${SERVER_ADDRESS}",
      "server_port": ${SERVER_PORT},
      "method": "2022-blake3-aes-128-gcm",
      "password": "${SHADOWSOCKS_PASSWORD}",
      "detour": "shadowtls-out",
      "multiplex": {
        "enabled": true,
        "padding": true,
        "protocol": "smux"
      }
    },
    {
      "type": "shadowtls",
      "tag": "shadowtls-out",
      "server": "${SERVER_ADDRESS}",
      "server_port": ${SERVER_PORT},
      "version": 3,
      "password": "${SHADOWTLS_USER_PASSWORD}",
      "tls": {
        "enabled": true,
        "server_name": "${HANDSHAKE_SERVER}",
        "utls": {
          "enabled": true,
          "fingerprint": "chrome"
        }
      }
    },
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    },
    {
      "type": "dns",
      "tag": "dns-out"
    }
  ],
  "route": {
    "rule_set": [
      {
        "type": "remote",
        "tag": "geosite-cn",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-cn.srs",
        "download_detour": "proxy"
      },
      {
        "type": "remote",
        "tag": "geoip-cn",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs",
        "download_detour": "proxy"
      }
    ],
    "rules": [
      {
        "protocol": "dns",
        "outbound": "dns-out"
      },
      {
        "network": "udp",
        "port": 443,
        "outbound": "block"
      },
      {
        "rule_set": "geoip-cn",
        "outbound": "direct"
      },
      {
        "rule_set": "geosite-cn",
        "outbound": "direct"
      },
      {
        "ip_is_private": true,
        "outbound": "direct"
      }
    ],
    "final": "proxy",
    "auto_detect_interface": true
  },
  "experimental": {
    "cache_file": {
      "enabled": true,
      "path": "cache.db",
      "store_fakeip": false
    }
  }
}
EOF

echo ""
echo "✓ 配置文件生成完成!"
echo ""
echo "生成的文件:"
echo "  服务端配置: ${SCRIPT_DIR}/server-config.json"
echo "  客户端配置: ${SCRIPT_DIR}/client-config.json"
echo ""

# 验证配置文件
echo "正在验证配置文件..."
if sing-box check -c "${SCRIPT_DIR}/server-config.json" > /dev/null 2>&1; then
    echo "✓ 服务端配置验证通过"
else
    echo "✗ 服务端配置验证失败"
fi

if sing-box check -c "${SCRIPT_DIR}/client-config.json" > /dev/null 2>&1; then
    echo "✓ 客户端配置验证通过"
else
    echo "✗ 客户端配置验证失败"
fi

echo ""
echo "=========================================="
echo "下一步操作:"
echo "=========================================="
echo ""
echo "服务端:"
echo "  1. 将 server-config.json 上传到服务器"
echo "  2. 确保防火墙开放端口 ${SERVER_PORT}"
echo "  3. 运行: sing-box run -c server-config.json"
echo ""
echo "客户端:"
echo "  1. 使用 client-config.json"
echo "  2. Linux/macOS 运行: sudo sing-box run -c client-config.json"
echo "  3. Windows 以管理员身份运行: sing-box run -c client-config.json"
echo ""
echo "配置参数摘要:"
echo "  服务器地址: ${SERVER_ADDRESS}:${SERVER_PORT}"
echo "  握手服务器: ${HANDSHAKE_SERVER}"
echo "  加密方法: 2022-blake3-aes-128-gcm"
echo "  协议: ShadowTLS v3 + Shadowsocks"
echo ""
echo "提示: 请妥善保管好生成的配置文件和密钥!"
echo "=========================================="
