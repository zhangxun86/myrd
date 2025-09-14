#!/bin/bash
# 一键设置代理环境变量和工具配置

echo "=== 设置代理环境变量 ==="

# 代理配置
PROXY_HTTP="http://127.0.0.1:8080"
PROXY_SOCKS="socks5://127.0.0.1:1080"

# 系统代理环境变量
export http_proxy=$PROXY_HTTP
export https_proxy=$PROXY_HTTP
export HTTP_PROXY=$PROXY_HTTP
export HTTPS_PROXY=$PROXY_HTTP
export no_proxy=localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8

echo "✅ 系统代理环境变量已设置"

# Git代理配置
echo "🔧 配置Git代理..."
git config --global http.proxy $PROXY_HTTP
git config --global https.proxy $PROXY_HTTP
git config --global http.https://github.com.proxy $PROXY_HTTP
echo "📦 Git代理配置完成"

# 创建Cargo代理配置
echo "🦀 配置Cargo代理..."
mkdir -p ~/.cargo
cat > ~/.cargo/config.toml << 'EOF'
[http]
proxy = "http://127.0.0.1:8080"

[https]  
proxy = "http://127.0.0.1:8080"

# 使用国内镜像加速
[source.crates-io]
replace-with = "tuna"

[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"
EOF
echo "🦀 Cargo代理和镜像配置完成"

# Flutter镜像配置
echo "📱 配置Flutter镜像..."
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_HOSTED_URL=https://pub.flutter-io.cn
echo "📱 Flutter镜像配置完成"

# 显示当前配置
echo ""
echo "📊 当前代理配置总览:"
echo "🌐 HTTP代理: $http_proxy"
echo "🔒 HTTPS代理: $https_proxy"
echo "🚫 不代理地址: $no_proxy"
echo ""

# 验证配置
echo "🔍 验证配置效果..."

# 测试Git代理
if git config --global --get http.proxy > /dev/null; then
    echo "✅ Git代理: $(git config --global --get http.proxy)"
else
    echo "❌ Git代理配置失败"
fi

# 测试Cargo配置
if [ -f ~/.cargo/config.toml ]; then
    echo "✅ Cargo配置文件已创建"
else
    echo "❌ Cargo配置文件创建失败"
fi

# 测试网络连通性
echo ""
echo "🌍 测试网络连通性..."
if curl --connect-timeout 5 --proxy $PROXY_HTTP https://github.com > /dev/null 2>&1; then
    echo "✅ GitHub访问正常"
else
    echo "❌ GitHub访问失败，请检查代理设置"
fi

if curl --connect-timeout 5 --proxy $PROXY_HTTP https://crates.io > /dev/null 2>&1; then
    echo "✅ Crates.io访问正常"
else
    echo "❌ Crates.io访问失败，请检查代理设置"
fi

echo ""
echo "🎯 代理环境配置完成！"
echo "💡 现在可以正常使用以下命令:"
echo "   git clone https://github.com/..."
echo "   cargo build"
echo "   flutter pub get"
echo "   ./auto_build.sh"
echo ""
echo "⚠️  重要提醒:"
echo "   1. 请确保代理服务正在运行 (运行 ./start_proxy.sh)"
echo "   2. 如需永久保存环境变量，请添加到 ~/.bashrc"
echo "   3. 遇到问题请参考 PROXY_SETUP_GUIDE.md"