#!/bin/bash

echo "🌐 使用Clash代理获取Flutter仓库依赖..."

# 设置代理环境变量
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890

# 设置Git代理配置
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890

# 设置Git SSL验证
git config --global http.sslVerify false

# 检查代理连接
echo "📡 检查代理连接状态..."
curl -s --connect-timeout 5 https://google.com > /dev/null && echo "✅ HTTPS代理连接正常" || echo "❌ HTTPS代理连接失败"

echo "🔄 清理Flutter缓存..."
cd flutter
flutter clean

echo "📦 获取Flutter依赖..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Flutter依赖获取成功！"
    echo "🚀 现在尝试构建APK..."
    flutter build apk --release
else
    echo "❌ Flutter依赖获取失败"
    echo "💡 尝试离线模式或手动下载依赖"
fi

