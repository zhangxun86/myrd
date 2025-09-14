#!/usr/bin/env bash
# 跳过 Rust 编译，使用已存在的占位符 .so 文件
echo "使用占位符 librustdesk.so，跳过 Rust 编译"
echo "占位符库位置: android/app/src/main/jniLibs/arm64-v8a/librustdesk.so"
echo "构建完成 - 使用占位符库"
