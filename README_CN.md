# sing-box 项目介绍

## 项目概述

**sing-box** 是一个通用代理平台（The universal proxy platform），旨在提供一个功能强大、高性能的网络代理解决方案。该项目使用 Go 语言开发，支持多种代理协议和功能。

### 基本信息

- **项目名称**: sing-box
- **开发者**: nekohasekai
- **开源协议**: GNU General Public License v3.0 (GPL-3.0)
- **开发语言**: Go (Go 1.24.7+)
- **官方文档**: https://sing-box.sagernet.org
- **源代码仓库**: https://github.com/SagerNet/sing-box

## 核心特性

### 1. 多协议支持

sing-box 支持广泛的代理协议，包括但不限于：

- **基础协议**:
  - Direct (直连)
  - Block (阻断)
  - DNS
  - HTTP
  - SOCKS (SOCKS4/SOCKS5)
  - Mixed (混合代理)
  - Redirect (重定向)

- **高级代理协议**:
  - Shadowsocks
  - ShadowTLS
  - VMess
  - VLESS
  - Trojan
  - Naive
  - Hysteria / Hysteria2
  - TUIC
  - SSH

- **VPN 和隧道**:
  - WireGuard
  - TUN (虚拟网络接口)
  - Tailscale

- **匿名网络**:
  - Tor

### 2. 路由和规则系统

- 强大的路由管理器，支持复杂的流量路由规则
- DNS 路由和解析功能
- 连接管理和流量控制
- 支持 GeoIP 和 GeoSite 数据库进行地理位置和域名匹配
- 规则集（Rule Set）的编译、转换和匹配功能

### 3. 实验性功能

- **Clash API**: 兼容 Clash 的 API 接口
- **V2Ray API**: 支持 V2Ray 的 API 功能
- **缓存文件系统**: 优化性能的缓存机制
- **本地化支持**: 多语言界面支持

### 4. 网络功能

- TCP Fast Open (TFO) 支持
- QUIC 协议支持
- gVisor 网络栈集成
- DHCP 客户端支持
- ACME 自动证书管理
- uTLS (Fingerprint) 支持

## 架构设计

### 核心组件

1. **Box (核心容器)**:
   - 主要的运行时容器，管理所有组件的生命周期
   - 位于 `box.go` 文件中

2. **Adapter (适配器层)**:
   - 提供统一的接口抽象
   - 包括 Inbound、Outbound、Endpoint 等适配器

3. **Route (路由层)**:
   - 网络管理器
   - 连接管理器
   - 路由规则处理

4. **DNS (域名解析)**:
   - DNS 传输管理器
   - DNS 路由器
   - 本地 DNS 解析

5. **Protocol (协议层)**:
   - 各种代理协议的具体实现
   - 支持 25+ 种不同的协议

6. **Transport (传输层)**:
   - 底层传输协议实现
   - 包括 TLS、WebSocket、gRPC 等

### 目录结构

```
sing-box/
├── adapter/          # 适配器接口和实现
├── box.go           # 核心 Box 实现
├── cmd/             # 命令行工具
│   └── sing-box/    # 主程序入口
├── common/          # 通用工具和库
├── constant/        # 常量定义
├── dns/             # DNS 功能
├── docs/            # 文档（中英文）
├── experimental/    # 实验性功能
├── log/             # 日志系统
├── option/          # 配置选项
├── protocol/        # 协议实现
├── route/           # 路由系统
├── service/         # 服务层
├── transport/       # 传输层
└── test/            # 测试文件
```

## 主要功能

### 1. 命令行工具

sing-box 提供了丰富的命令行工具：

- **run**: 运行代理服务
- **check**: 检查配置文件
- **format**: 格式化配置文件
- **merge**: 合并多个配置文件
- **version**: 显示版本信息

#### GeoIP 工具:
- `geoip lookup`: 查询 IP 地理位置
- `geoip export`: 导出 GeoIP 数据
- `geoip list`: 列出 GeoIP 数据库

#### GeoSite 工具:
- `geosite lookup`: 查询域名规则
- `geosite export`: 导出 GeoSite 数据
- `geosite list`: 列出 GeoSite 数据库
- `geosite matcher`: 域名匹配工具

#### 规则集工具:
- `rule-set compile`: 编译规则集
- `rule-set convert`: 转换规则集格式
- `rule-set decompile`: 反编译规则集
- `rule-set format`: 格式化规则集
- `rule-set match`: 匹配规则
- `rule-set merge`: 合并规则集
- `rule-set upgrade`: 升级规则集

#### 生成工具:
- `generate wireguard`: 生成 WireGuard 密钥对
- `generate tls`: 生成 TLS 证书
- `generate ech`: 生成 ECH (Encrypted Client Hello) 配置
- `generate vapid`: 生成 VAPID 密钥

#### 实用工具:
- `tools connect`: 测试连接
- `tools fetch`: 抓取 HTTP 资源
- `tools synctime`: 同步系统时间

### 2. 配置系统

sing-box 使用 JSON 格式的配置文件，支持：

- 多个配置文件合并
- 配置目录批量加载
- 配置验证和格式化
- 热重载（部分支持）

### 3. 服务管理

- systemd 集成 (`.fpm_systemd`)
- OpenWrt 支持 (`.fpm_openwrt`)
- 守护进程模式
- 调试模式和 HTTP 调试接口

## 构建和安装

### 构建标签

项目使用以下默认构建标签：
```
with_gvisor,with_quic,with_dhcp,with_wireguard,
with_utls,with_acme,with_clash_api,with_tailscale,
with_ccm,with_ocm
```

### 构建命令

```bash
# 标准构建
make build

# 安装到系统
make install

# 竞态检测构建
make race

# 生成命令补全
make generate_completions
```

### 代码质量工具

```bash
# 代码格式化
make fmt

# 文档格式化
make fmt_docs

# 代码检查
make lint
```

## 客户端支持

项目包含多平台客户端支持：

- **libbox**: 库文件形式，用于集成到其他应用
- Android 客户端支持
- iOS 客户端支持
- Windows、macOS、Linux 桌面支持

## 容器化部署

提供了 Docker 支持：

- `Dockerfile`: 完整镜像构建
- `Dockerfile.binary`: 仅二进制文件的轻量镜像

## 依赖项

主要依赖包括：

- **网络库**: 
  - `github.com/sagernet/sing`: 核心网络库
  - `github.com/sagernet/gvisor`: 用户态网络栈
  - `github.com/sagernet/quic-go`: QUIC 协议支持

- **代理协议**:
  - `github.com/sagernet/sing-shadowsocks`: Shadowsocks 实现
  - `github.com/sagernet/sing-vmess`: VMess 实现
  - `github.com/sagernet/wireguard-go`: WireGuard 实现

- **TLS 和加密**:
  - `github.com/metacubex/utls`: uTLS 支持
  - `github.com/caddyserver/certmagic`: 证书管理

- **DNS**:
  - `github.com/miekg/dns`: DNS 库
  - `github.com/libdns/*`: DNS 提供商支持

- **实用工具**:
  - `github.com/spf13/cobra`: CLI 框架
  - `go.uber.org/zap`: 日志库
  - `github.com/oschwald/maxminddb-golang`: GeoIP 数据库

## 安全性和许可

### 开源许可

本项目采用 **GPL-3.0** 许可证，这意味着：

- 可以自由使用、修改和分发
- 修改后的代码必须同样开源
- 不允许未经许可使用项目名称或暗示关联

### 版权信息

```
Copyright (C) 2022 by nekohasekai <contact-sagernet@sekai.icu>
```

### 安全特性

- 支持现代加密算法
- TLS 1.3 支持
- Encrypted Client Hello (ECH) 支持
- 证书固定和验证
- 内存安全（Go 语言特性）

## 使用场景

sing-box 适用于以下场景：

1. **网络代理**: 作为正向或反向代理服务器
2. **流量路由**: 根据规则智能路由网络流量
3. **VPN 服务**: 提供 WireGuard、TUN 等 VPN 功能
4. **隐私保护**: 通过代理和加密保护网络隐私
5. **开发测试**: 网络调试和测试工具
6. **企业网络**: 企业级网络管理和访问控制

## 性能特点

- **高性能**: Go 语言并发特性，支持大量并发连接
- **低延迟**: 优化的网络栈和协议实现
- **资源高效**: 内存和 CPU 使用效率高
- **可扩展**: 模块化设计，易于扩展新功能

## 社区和支持

- **官方文档**: https://sing-box.sagernet.org
- **GitHub 仓库**: https://github.com/SagerNet/sing-box
- **问题反馈**: 通过 GitHub Issues 提交
- **赞助支持**: 由 [Warp](https://go.warp.dev/sing-box) 赞助

## 开发状态

项目处于活跃开发状态，定期更新：

- 持续的功能改进
- 安全更新和漏洞修复
- 新协议和功能支持
- 文档和示例完善

## 文档资源

项目提供完整的文档：

- **安装指南**: 详细的安装步骤
- **配置参考**: 完整的配置选项说明
- **迁移指南**: 版本升级和迁移帮助
- **更新日志**: 版本变更记录
- **已废弃功能**: 不推荐使用的功能说明

文档支持中英文双语，位于 `docs/` 目录。

## 总结

sing-box 是一个功能全面、性能优异的通用代理平台，适合从个人用户到企业级应用的各种网络代理需求。其模块化的设计、丰富的协议支持和活跃的开发社区使其成为网络代理领域的优秀开源项目。

---

**注意**: 本文档是对 sing-box 项目的概述性介绍。详细的使用说明、配置方法和 API 文档请参考官方文档网站。
