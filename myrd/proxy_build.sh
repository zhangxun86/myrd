#!/bin/bash

echo "🌐 设置代理环境进行构建..."

# 设置 Clash 代理
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890

# 设置 Git 代理
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890

# 检查代理状态
echo "📡 检查代理连接..."
curl -s --connect-timeout 5 -o /dev/null google.com && echo "✅ 代理连接成功" || echo "❌ 代理连接失败"

echo "🚀 开始 Flutter 构建..."
cd flutter
flutter clean
flutter pub get
flutter build apk --release

