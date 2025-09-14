#!/bin/bash

# 快速安全上传脚本
echo "=== RustDesk项目安全上传 ==="

# 移除可能包含敏感信息的文件
echo "清理敏感文件..."
rm -f Cargo.lock
rm -f target/debug/build/*/out/config.log
rm -rf target/release/
rm -rf target/debug/
find . -name "*.log" -type f -delete
find . -name "*.tmp" -type f -delete

# 确保.gitignore包含必要条目
echo "
# 构建产物
target/
Cargo.lock

# 临时文件
*.log
*.tmp
*.bak

# 敏感配置
**/config.log
**/.env
" >> .gitignore

# 添加文件并提交
echo "添加文件到git..."
git add .
git add -u

echo "提交更改..."
git commit -m "RustDesk Android APK构建项目 - 安全版本

核心功能:
- 包名更改为com.rustdesk.6100cn  
- 自定义服务器配置
- 移除防检测功能
- Android签名配置
- 简化编译策略
- 完整开发文档

详情: 见DEVELOPMENT_LOG.md"

echo "推送到远程仓库..."
git push -f origin master

echo "=== 上传完成 ==="