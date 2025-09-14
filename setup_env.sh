#!/bin/bash

# RustDesk Android 项目环境自动配置脚本
# 版本: 2025-09-13
# 支持: Ubuntu 20.04+

set -e  # 遇到错误立即退出

echo "🚀 RustDesk Android 环境配置开始..."
echo "📋 检测系统环境..."

# 检查系统版本
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "系统: $NAME $VERSION"
else
    echo "⚠️ 无法检测系统版本，继续安装..."
fi

# 更新系统包管理器
echo "📦 更新系统包管理器..."
sudo apt update

# 安装基础依赖
echo "🔧 安装基础构建工具..."
sudo apt install -y \
    curl \
    wget \
    git \
    unzip \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    libc6-dev \
    libssl-dev \
    ca-certificates \
    gnupg \
    lsb-release

# 1. 安装 Java JDK 11
echo "☕ 安装 Java JDK 11..."
if ! java -version 2>&1 | grep -q "11\."; then
    sudo apt install -y openjdk-11-jdk
    
    # 配置 JAVA_HOME
    export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
    echo "export JAVA_HOME=\"/usr/lib/jvm/java-11-openjdk-amd64\"" >> ~/.bashrc
    echo "export PATH=\"\$PATH:\$JAVA_HOME/bin\"" >> ~/.bashrc
    
    echo "✅ Java JDK 11 安装完成"
    java -version
else
    echo "✅ Java JDK 11 已安装"
fi

# 2. 安装 Rust 1.75
echo "🦀 安装 Rust 工具链..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.75.0
    source "$HOME/.cargo/env"
    echo "✅ Rust 安装完成"
else
    echo "✅ Rust 已安装"
fi

# 添加 Android 目标和 cargo-ndk
source "$HOME/.cargo/env"
rustup target add aarch64-linux-android
cargo install cargo-ndk

# 3. 安装 Android SDK 和 NDK
echo "📱 安装 Android SDK 和 NDK..."
ANDROID_HOME="$HOME/android-sdk"
ANDROID_NDK_VERSION="27.0.12077973"

if [[ ! -d "$ANDROID_HOME" ]]; then
    # 下载 Android Command Line Tools
    mkdir -p "$ANDROID_HOME"
    cd "$ANDROID_HOME"
    
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
    unzip -q commandlinetools-linux-11076708_latest.zip
    mkdir -p cmdline-tools/latest
    mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
    rm commandlinetools-linux-11076708_latest.zip
    
    # 配置环境变量
    export ANDROID_HOME="$HOME/android-sdk"
    export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
    
    # 写入 .bashrc
    echo "export ANDROID_HOME=\"$HOME/android-sdk\"" >> ~/.bashrc
    echo "export ANDROID_NDK_HOME=\"\$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION\"" >> ~/.bashrc
    echo "export PATH=\"\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools\"" >> ~/.bashrc
    
    # 接受许可协议并安装组件
    yes | sdkmanager --licenses
    sdkmanager "platform-tools" "platforms;android-30" "platforms;android-33" "platforms;android-34"
    sdkmanager "build-tools;34.0.0" "ndk;$ANDROID_NDK_VERSION"
    
    echo "✅ Android SDK 和 NDK 安装完成"
else
    echo "✅ Android SDK 已存在"
fi

# 4. 安装 Flutter 3.24.5
echo "🐦 安装 Flutter 3.24.5..."
FLUTTER_HOME="$HOME/flutter"

if [[ ! -d "$FLUTTER_HOME" ]]; then
    cd "$HOME"
    wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
    tar -xf flutter_linux_3.24.5-stable.tar.xz
    rm flutter_linux_3.24.5-stable.tar.xz
    
    # 配置 Flutter 环境变量
    export PATH="$PATH:$HOME/flutter/bin"
    echo "export PATH=\"\$PATH:$HOME/flutter/bin\"" >> ~/.bashrc
    
    # Flutter 初始配置
    flutter config --android-sdk "$ANDROID_HOME"
    flutter doctor
    
    echo "✅ Flutter 3.24.5 安装完成"
else
    echo "✅ Flutter 已安装"
fi

# 5. 配置 libclang 路径 (Rust 编译需要)
echo "⚙️ 配置 libclang 路径..."
LIBCLANG_PATH=$(find /usr -name "libclang.so*" 2>/dev/null | head -1 | xargs dirname 2>/dev/null || echo "/usr/lib/x86_64-linux-gnu")
export LIBCLANG_PATH="$LIBCLANG_PATH"
echo "export LIBCLANG_PATH=\"$LIBCLANG_PATH\"" >> ~/.bashrc

# 6. 最终验证
echo "🔍 环境验证..."
source ~/.bashrc

echo "📋 安装摘要:"
echo "  Java版本: $(java -version 2>&1 | head -1)"
echo "  Rust版本: $(rustc --version)"
echo "  Flutter版本: $(flutter --version | head -1)"
echo "  Android SDK: $ANDROID_HOME"
echo "  Android NDK: $ANDROID_NDK_HOME"

# 创建快速构建脚本
echo "📝 创建快速构建脚本..."
cat > ~/build_rustdesk.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 开始 RustDesk Android 构建..."

# 检查环境
source ~/.bashrc

# 进入项目目录
cd /root/rustdesk/myrd

echo "🔧 编译 Rust 原生库..."
cargo ndk -t arm64-v8a build --release

echo "📱 构建 Flutter APK..."
cd flutter
flutter clean
flutter pub get
flutter build apk --target-platform android-arm64 --release

echo "✅ 构建完成！"
echo "📦 APK 位置: build/app/outputs/flutter-apk/"
ls -la build/app/outputs/flutter-apk/
EOF

chmod +x ~/build_rustdesk.sh

echo ""
echo "🎉 环境配置完成！"
echo ""
echo "⚡ 快速开始："
echo "  1. 重新加载环境: source ~/.bashrc"
echo "  2. 验证环境: flutter doctor"
echo "  3. 构建项目: ~/build_rustdesk.sh"
echo ""
echo "📋 重要路径："
echo "  项目目录: /root/rustdesk/myrd"
echo "  快速构建: ~/build_rustdesk.sh"
echo "  Java Home: $JAVA_HOME"
echo "  Android SDK: $ANDROID_HOME"
echo "  Flutter: $HOME/flutter"
echo ""
echo "⚠️ 请执行以下命令使环境变量生效："
echo "   source ~/.bashrc"
echo ""