#!/usr/bin/env python3
"""
RustDesk 依赖包下载服务器
使用方法: python3 serve_deps.py
默认端口: 8000
下载地址: http://[服务器IP]:8000/rustdesk-deps-20250913.tar.gz
"""

import http.server
import socketserver
import os
import sys

PORT = 8000
DEPS_FILE = "/root/rustdesk-deps-20250913.tar.gz"

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        super().end_headers()

def main():
    # 检查依赖包是否存在
    if not os.path.exists(DEPS_FILE):
        print(f"❌ 错误: 依赖包文件不存在: {DEPS_FILE}")
        sys.exit(1)
    
    # 获取文件大小
    file_size = os.path.getsize(DEPS_FILE)
    file_size_mb = file_size / (1024 * 1024)
    
    print(f"🚀 启动 RustDesk 依赖包下载服务器...")
    print(f"📦 依赖包文件: {DEPS_FILE}")
    print(f"📊 文件大小: {file_size_mb:.1f} MB")
    print(f"🌐 服务端口: {PORT}")
    print(f"")
    print(f"📥 下载地址: http://[服务器IP]:{PORT}/rustdesk-deps-20250913.tar.gz")
    print(f"🔗 本地测试: http://localhost:{PORT}/rustdesk-deps-20250913.tar.gz")
    print(f"")
    print(f"⚡ 同事使用命令:")
    print(f"   wget http://[服务器IP]:{PORT}/rustdesk-deps-20250913.tar.gz")
    print(f"   tar -xzf rustdesk-deps-20250913.tar.gz -C ~/")
    print(f"")
    print(f"按 Ctrl+C 停止服务")
    print(f"=" * 60)
    
    # 创建软链接到根目录以便访问
    link_path = f"/root/rustdesk-deps-20250913.tar.gz"
    if not os.path.exists(link_path):
        os.symlink(DEPS_FILE, link_path)
    
    # 切换到根目录
    os.chdir("/root")
    
    # 启动服务器
    with socketserver.TCPServer(("", PORT), CustomHTTPRequestHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n🛑 服务器已停止")
            httpd.shutdown()

if __name__ == "__main__":
    main()