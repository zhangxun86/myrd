# 依赖包备份和分发指南

## 📦 依赖包管理策略

### 当前依赖包状态
- **完整依赖包**：rustdesk-deps-20250913.tar.gz
- **大小**：约 6GB
- **内容**：所有构建所需的依赖文件
- **备份位置**：198.11.178.210:/root/

---

## 🎯 为新同事创建依赖包下载方案

### 方案一：SFTP 服务器下载（推荐）

新同事可以直接从备份服务器下载：

```bash
# 在新服务器上创建项目目录
cd /root/rustdesk/myrd

# 使用 SFTP 下载依赖包
sftp root@198.11.178.210
# 输入密码：Tb123456
get /root/rustdesk-deps-20250913.tar.gz
exit

# 解压依赖包
tar -xzf rustdesk-deps-20250913.tar.gz

# 设置正确的权限
chown -R root:root /root/rustdesk
chmod -R 755 /root/rustdesk
```

### 方案二：创建 HTTP 下载服务

我们可以在当前服务器上创建一个简单的 HTTP 文件服务：

```bash
# 创建共享目录
mkdir -p /root/shared-deps
cp /root/rustdesk-deps-20250913.tar.gz /root/shared-deps/

# 启动简单的 HTTP 服务器
cd /root/shared-deps
python3 -m http.server 8080

# 新同事可以通过以下方式下载
# wget http://[服务器IP]:8080/rustdesk-deps-20250913.tar.gz
```

### 方案三：云存储上传

可以将依赖包上传到云存储服务：

```bash
# 上传到云存储（需要根据具体服务配置）
# 示例：上传到 AWS S3, Google Cloud, 或阿里云 OSS
# 然后提供下载链接给新同事
```

---

## 📋 依赖包内容详情

### 包含的关键依赖
```
rustdesk-deps-20250913.tar.gz 包含：

1. Flutter 相关：
   - ~/.pub-cache/           # Pub 包缓存
   - flutter SDK 文件
   - dart 包依赖

2. Rust 相关：
   - ~/.cargo/registry/      # Cargo 注册表缓存
   - target/ 编译输出
   - 第三方 crate 依赖

3. Android 相关：
   - Android SDK 组件
   - NDK 工具链
   - Gradle 缓存

4. 系统库：
   - 编译工具链
   - 链接库文件
```

### 解压后的目录结构
```
解压后应该得到：
├── .cargo/              # Rust 包管理器缓存
├── .pub-cache/          # Flutter/Dart 包缓存  
├── android-sdk/         # Android SDK
├── flutter/             # Flutter SDK
├── gradle-cache/        # Gradle 构建缓存
└── system-libs/         # 系统依赖库
```

---

## 🔧 新同事快速环境搭建

### 使用依赖包的完整流程

```bash
# 1. 系统准备
sudo yum update -y
sudo yum install -y wget curl git unzip vim

# 2. 下载项目代码
cd /root/rustdesk
git clone https://github.com/zhangxun86/myrd.git
cd myrd

# 3. 下载依赖包
sftp root@198.11.178.210
get /root/rustdesk-deps-20250913.tar.gz
exit

# 4. 解压并配置依赖
tar -xzf rustdesk-deps-20250913.tar.gz

# 5. 设置环境变量
cat >> ~/.bashrc << 'EOF'
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export ANDROID_HOME=/root/android-sdk  
export ANDROID_SDK_ROOT=/root/android-sdk
export PATH="/root/flutter/bin:$PATH"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
EOF

source ~/.bashrc

# 6. 验证环境
java -version
flutter doctor
cargo --version

# 7. 构建项目
cd flutter
flutter build apk --release --no-shrink --build-name=1.4.2 --build-number=60
```

---

## ⚠️ 依赖包使用注意事项

### 关键警告
1. **版本兼容性**：依赖包与特定版本绑定，不要随意升级
2. **路径依赖**：某些工具可能包含绝对路径，需要调整
3. **权限问题**：解压后必须设置正确的文件权限
4. **环境变量**：必须正确配置所有必要的环境变量

### 故障排查
```bash
# 如果遇到路径问题，检查并修复：
find /root -name "*.sh" -exec sed -i 's|/old/path|/new/path|g' {} \;

# 如果遇到权限问题：
chmod +x /root/flutter/bin/flutter
chmod +x /root/android-sdk/cmdline-tools/latest/bin/*

# 如果遇到库链接问题：
ldconfig
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
```

---

## 🔄 依赖包更新策略

### 何时需要更新依赖包
- Flutter 或 Rust 版本升级时
- 添加新的第三方库时  
- Android SDK 或 NDK 版本更新时
- 系统环境发生重大变化时

### 创建新的依赖包
```bash
# 在当前工作环境中创建新的依赖包
cd /root

# 打包所有相关依赖
tar -czf rustdesk-deps-$(date +%Y%m%d).tar.gz \
    .cargo/ \
    .pub-cache/ \
    android-sdk/ \
    flutter/ \
    rustdesk/myrd/target/

# 上传到备份服务器
scp rustdesk-deps-$(date +%Y%m%d).tar.gz root@198.11.178.210:/root/
```

---

## 📊 依赖包大小优化

### 当前包大小分析
```
总大小：6GB
├── Flutter/Dart 缓存: ~2GB
├── Rust 编译缓存: ~2GB  
├── Android SDK: ~1.5GB
└── 其他工具: ~0.5GB
```

### 优化建议
1. **定期清理**：删除不必要的中间文件
2. **分层打包**：基础环境 + 项目特定依赖
3. **压缩优化**：使用更高压缩率
4. **增量更新**：只更新变化的部分

---

## 🌍 国际化部署考虑

### 美国服务器优势
- **网络直连**：无需代理配置
- **下载速度**：访问 GitHub、Google 服务更快
- **时区一致**：便于国际团队协作

### 多地区部署建议
```bash
# 可以在多个地区创建依赖包镜像
# 美国：198.11.178.210 (主)
# 欧洲：[备用服务器] (镜像)  
# 亚洲：[备用服务器] (镜像)
```

---

**依赖包管理总结：通过完整的依赖包备份，新同事可以在任何新服务器上快速搭建开发环境，避免网络问题和版本冲突。**