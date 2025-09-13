# 📦 RustDesk 依赖包下载指南

**快速部署方案** | **避免重复环境配置**

---

## 🎯 依赖包信息

- **文件名**: `rustdesk-deps-20250913.tar.gz`
- **文件大小**: 150MB (压缩后)
- **解压后大小**: 约6.5GB
- **包含内容**: 
  - Flutter依赖缓存 (`~/.pub-cache`)
  - Rust工具链 (`~/.cargo`, `~/.rustup`)
  - Android SDK/NDK (`~/android-sdk`)

---

## 🚀 快速下载部署

### 方案1: 从本服务器下载 (推荐)

**第一步: 启动下载服务**
```bash
# 在当前服务器上启动依赖包下载服务
cd /root/rustdesk
python3 serve_deps.py

# 服务会显示下载地址，类似:
# 📥 下载地址: http://[服务器IP]:8000/rustdesk-deps-20250913.tar.gz
```

**第二步: 在新服务器下载**
```bash
# 替换[服务器IP]为实际IP地址
wget http://[服务器IP]:8000/rustdesk-deps-20250913.tar.gz

# 验证下载完整性
ls -lh rustdesk-deps-20250913.tar.gz
# 应该显示约150MB大小
```

**第三步: 解压安装**
```bash
# 解压到用户主目录
tar -xzf rustdesk-deps-20250913.tar.gz -C ~/

# 验证解压结果
ls -la ~/.pub-cache ~/.cargo ~/.rustup ~/android-sdk

# 配置环境变量
echo 'export ANDROID_HOME="$HOME/android-sdk"' >> ~/.bashrc
echo 'export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.0.12077973"' >> ~/.bashrc
echo 'export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"' >> ~/.bashrc
source ~/.bashrc

echo "✅ 依赖包安装完成!"
```

### 方案2: 通过云存储 (备用)

如果有云存储服务，可以上传依赖包:
```bash
# 上传到云存储 (需要根据具体服务商调整)
# 示例 - AWS S3
# aws s3 cp rustdesk-deps-20250913.tar.gz s3://your-bucket/

# 示例 - 阿里云OSS  
# ossutil cp rustdesk-deps-20250913.tar.gz oss://your-bucket/

# 同事下载
# wget https://your-cloud-url/rustdesk-deps-20250913.tar.gz
```

---

## 🔧 依赖包验证

下载解压后，验证依赖包完整性:

```bash
# 验证Flutter依赖
ls ~/.pub-cache/hosted/pub.dev/ | wc -l
# 应该显示多个包 (预期: 50+)

# 验证Rust工具链
rustc --version || echo "需要安装Rust"
cargo --version || echo "需要安装Cargo"

# 验证Android SDK
ls ~/android-sdk/platforms/
# 应该显示: android-30, android-33, android-34

# 验证Android NDK
ls ~/android-sdk/ndk/
# 应该显示: 27.0.12077973
```

---

## ⚠️ 注意事项

### 网络要求
- **下载服务端口**: 8000
- **防火墙**: 确保8000端口开放
- **网络稳定**: 150MB文件需要稳定连接

### 权限要求
- **用户权限**: 确保有写入 `~/` 目录的权限
- **执行权限**: 确保有执行 `.bashrc` 的权限

### 空间要求
- **下载空间**: 至少200MB (下载文件+临时空间)
- **解压空间**: 至少7GB (解压后实际占用)
- **总计空间**: 建议10GB+可用空间

---

## 🚨 故障排除

### 问题1: 下载失败
```bash
# 检查网络连接
ping [服务器IP]

# 检查端口是否开放
telnet [服务器IP] 8000

# 重试下载
wget --continue http://[服务器IP]:8000/rustdesk-deps-20250913.tar.gz
```

### 问题2: 解压失败
```bash
# 检查文件完整性
ls -lh rustdesk-deps-20250913.tar.gz
# 文件大小应该是150MB左右

# 验证压缩包
tar -tzf rustdesk-deps-20250913.tar.gz | head -10

# 重新解压
rm -rf ~/.pub-cache ~/.cargo ~/.rustup ~/android-sdk
tar -xzf rustdesk-deps-20250913.tar.gz -C ~/
```

### 问题3: 环境变量无效
```bash
# 重新设置环境变量
cat >> ~/.bashrc << 'EOF'
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.0.12077973"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$HOME/.cargo/bin"
EOF

# 重新加载
source ~/.bashrc

# 验证
echo $ANDROID_HOME
echo $ANDROID_NDK_HOME
```

---

## 📊 性能对比

| 部署方案 | 时间估计 | 网络需求 | 难度等级 |
|----------|----------|----------|----------|
| **依赖包部署** | 10-20分钟 | 150MB下载 | ⭐⭐ 简单 |
| **完整环境配置** | 30-60分钟 | 2-3GB下载 | ⭐⭐⭐⭐ 中等 |

**结论**: 使用依赖包可以节省 **70%** 的部署时间！

---

## 🎯 成功标志

### ✅ 下载成功
- 文件大小正确 (约150MB)
- 下载完整无中断
- 文件可以正常解压

### ✅ 安装成功  
- 所有目录都已创建
- 环境变量设置正确
- 工具链版本验证通过

### ✅ 验证成功
- `flutter doctor` 无错误
- `rustc --version` 显示1.75+
- `java -version` 显示Java 11

---

## 📞 技术支持

如果依赖包部署遇到问题，可以回退到完整环境配置:

```bash
# 清理残留文件
rm -rf ~/.pub-cache ~/.cargo ~/.rustup ~/android-sdk

# 执行完整环境配置
cd /root/myrd
chmod +x setup_env.sh
./setup_env.sh
source ~/.bashrc
```

---

**💡 建议**: 第一次部署建议使用依赖包方案，如果遇到问题再使用完整环境配置作为备选方案。

---

*文档版本: v1.0*  
*更新时间: 2025-09-13*  
*依赖包版本: 20250913*