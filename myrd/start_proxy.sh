#!/bin/bash
# 启动代理服务并设置环境变量

echo "=== 启动网络代理服务 ==="

# 检查V2Ray是否已运行
if pgrep -f "v2ray" > /dev/null; then
    echo "V2Ray已在运行"
else
    echo "启动V2Ray..."
    # 注意：需要先配置好V2Ray，这里提供启动模板
    if [ -f "/opt/v2ray/v2ray" ] && [ -f "/opt/v2ray/config.json" ]; then
        cd /opt/v2ray
        nohup ./v2ray -config config.json > v2ray.log 2>&1 &
        sleep 3
        echo "V2Ray启动完成"
    else
        echo "⚠️  V2Ray未安装或配置文件不存在"
        echo "请先按照PROXY_SETUP_GUIDE.md安装配置V2Ray"
        echo "或使用其他代理软件，然后修改本脚本"
    fi
fi

# 设置代理环境变量
export http_proxy=http://127.0.0.1:8080
export https_proxy=http://127.0.0.1:8080
export HTTP_PROXY=http://127.0.0.1:8080
export HTTPS_PROXY=http://127.0.0.1:8080
export no_proxy=localhost,127.0.0.1,192.168.0.0/16

echo "✅ 代理环境变量已设置"
echo "📡 HTTP代理: http://127.0.0.1:8080"
echo "🧦 SOCKS5代理: socks5://127.0.0.1:1080"

# 测试连通性
echo "🔍 测试代理连通性..."
if curl --connect-timeout 10 --proxy http://127.0.0.1:8080 https://httpbin.org/ip > /dev/null 2>&1; then
    echo "✅ 代理连接正常"
    echo "🌍 当前IP信息:"
    curl --proxy http://127.0.0.1:8080 https://httpbin.org/ip 2>/dev/null | grep -o '"origin": "[^"]*"'
else
    echo "❌ 代理连接失败，请检查配置"
    echo "💡 提示：请确保代理服务正在运行，端口8080可用"
fi

echo ""
echo "🚀 代理已启动，现在可以："
echo "   1. 运行 source ./setup_proxy_env.sh 完整配置开发环境"
echo "   2. 直接使用 git clone、cargo build 等命令"
echo "   3. 运行项目构建脚本"