# sing-box 配置模板

本目录提供 sing-box 的标准配置模板，帮助用户快速生成服务端和客户端配置文件。

## 版本兼容性

这些模板适用于 sing-box 1.12.15 及更高版本，使用最新的配置语法。

## 模板说明

### 1. ShadowTLS + Shadowsocks 组合（推荐）

这是目前最主流和推荐的配置组合：

- **服务端配置**: `server-shadowtls-shadowsocks.json`
  - 入站：ShadowTLS v3 + Shadowsocks 2022-blake3-aes-128-gcm
  - 出站：direct（直连）
  - 包含基础日志配置

- **客户端配置**: `client-shadowtls-shadowsocks.json`
  - 入站：TUN（虚拟网卡）
  - 出站：Shadowsocks + ShadowTLS v3
  - 包含完整的 DNS、路由规则、DNS 缓存配置

### 特性

- ✅ 使用 ShadowTLS v3 协议（最新版本）
- ✅ 使用 Shadowsocks 2022-blake3 加密方法（推荐）
- ✅ 服务端配置简洁高效
- ✅ 客户端包含智能 DNS 分流
- ✅ 客户端包含国内外路由规则
- ✅ 支持 DNS 缓存优化性能

## 使用方法

### 1. 生成密钥

使用 sing-box 自带工具生成所需密钥：

```bash
# 生成 Shadowsocks 密码（16字节，用于 2022-blake3-aes-128-gcm）
sing-box generate rand --base64 16

# 生成 ShadowTLS 密码
sing-box generate rand --base64 16
```

### 2. 配置服务端

1. 复制 `server-shadowtls-shadowsocks.json` 到服务器
2. 修改以下字段：
   - `inbounds[0].password`: 填入生成的 ShadowTLS 密码
   - `inbounds[0].users[0].password`: 填入生成的 ShadowTLS 用户密码
   - `inbounds[0].handshake.server`: 修改为真实的握手服务器（如 www.bing.com）
   - `inbounds[1].password`: 填入生成的 Shadowsocks 密码
   - `inbounds[0].listen_port`: 根据需要修改监听端口（默认 443）

3. 运行服务端：
```bash
sing-box run -c server-shadowtls-shadowsocks.json
```

### 3. 配置客户端

1. 复制 `client-shadowtls-shadowsocks.json` 到客户端设备
2. 修改以下字段：
   - `outbounds[0].server`: 填入服务器 IP 或域名
   - `outbounds[0].server_port`: 填入服务端监听端口
   - `outbounds[0].detour`: 确保指向 shadowtls-out
   - `outbounds[1].password`: 填入与服务端相同的 ShadowTLS 用户密码
   - `outbounds[1].tls.server_name`: 填入与服务端握手服务器相同的域名
   - 根据需要调整 DNS 服务器和路由规则

3. 运行客户端（需要管理员权限）：
```bash
# Linux/macOS
sudo sing-box run -c client-shadowtls-shadowsocks.json

# Windows（以管理员身份运行 PowerShell）
sing-box run -c client-shadowtls-shadowsocks.json
```

### 4. 验证配置

在运行前可以验证配置文件格式：

```bash
sing-box check -c server-shadowtls-shadowsocks.json
sing-box check -c client-shadowtls-shadowsocks.json
```

## 配置说明

### 服务端配置要点

1. **双层入站**：
   - ShadowTLS 提供流量伪装
   - Shadowsocks 提供加密代理

2. **握手服务器**：
   - 选择稳定的 HTTPS 网站（如 www.bing.com, www.microsoft.com）
   - 必须支持 TLS 1.3
   - 建议选择延迟低的服务器

3. **端口选择**：
   - 建议使用 443 端口（标准 HTTPS 端口）
   - 可以降低被检测的风险

### 客户端配置要点

1. **TUN 模式**：
   - 创建虚拟网卡接管系统流量
   - `auto_route`: 自动配置路由
   - 需要管理员/root 权限

2. **DNS 配置**：
   - 本地 DNS：用于国内域名解析
   - 远程 DNS：用于国外域名解析（通过代理）
   - DNS 缓存：提高解析速度

3. **路由规则**：
   - 国内 IP 直连
   - 国外 IP 走代理
   - 可以根据需要添加自定义规则

4. **性能优化**：
   - DNS 缓存容量设置为 10000
   - 启用 TCP Fast Open
   - 使用 2022 系列加密方法（性能更好）

## 自定义配置

### 添加更多用户（服务端）

在服务端配置的 `users` 数组中添加更多用户：

```json
"users": [
  {
    "name": "user1",
    "password": "生成的密码1"
  },
  {
    "name": "user2",
    "password": "生成的密码2"
  }
]
```

### 修改日志级别

调整日志详细程度（trace, debug, info, warn, error, fatal, panic）：

```json
"log": {
  "level": "info"
}
```

### 添加自定义路由规则

在客户端的 `route.rules` 中添加规则，例如特定域名走代理：

```json
{
  "domain": ["example.com"],
  "outbound": "proxy"
}
```

## 常见问题

### 1. 连接失败

- 检查服务端是否正常运行
- 确认服务器防火墙开放了对应端口
- 验证密码配置是否一致
- 检查服务器 IP/域名和端口是否正确

### 2. DNS 解析问题

- 检查 DNS 服务器是否可访问
- 尝试使用其他 DNS 服务器（如 1.1.1.1, 8.8.8.8）
- 检查 DNS 规则是否正确配置

### 3. 性能问题

- 考虑使用更快的加密方法
- 调整 DNS 缓存大小
- 优化路由规则减少不必要的匹配

## 进阶功能

### 使用规则集（Rule Set）

可以使用预编译的规则集来简化配置：

```json
"route": {
  "rule_set": [
    {
      "type": "remote",
      "tag": "geosite-cn",
      "format": "binary",
      "url": "https://example.com/geosite-cn.srs"
    }
  ],
  "rules": [
    {
      "rule_set": "geosite-cn",
      "outbound": "direct"
    }
  ]
}
```

### 启用 Clash API

在 `experimental` 中启用 Clash API 可以使用 Clash 兼容的客户端：

```json
"experimental": {
  "clash_api": {
    "external_controller": "127.0.0.1:9090",
    "secret": "your-secret"
  }
}
```

## 安全建议

1. **定期更换密码**：建议每月更换一次密钥
2. **使用强密码**：使用 sing-box 生成的随机密码
3. **及时更新**：保持 sing-box 版本更新以获得安全补丁
4. **限制访问**：仅授权信任的用户访问
5. **监控日志**：定期检查日志发现异常活动

## 相关资源

- [官方文档](https://sing-box.sagernet.org)
- [配置参考](https://sing-box.sagernet.org/configuration/)
- [GitHub 仓库](https://github.com/SagerNet/sing-box)

## 更新日志

- 2026-01-08: 创建模板，适配 sing-box 1.12.15+
