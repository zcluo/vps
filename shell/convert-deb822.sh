#!/bin/bash

set -euo pipefail

DEFAULT_SIGNED_BY=""
INPUT_FILE=""
OUTPUT_FILE=""
# 使用示例： ./convert-deb822.sh --default-signed-by /path/to/default.key 输入文件 输出文件
# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case "$1" in
        --default-signed-by)
            DEFAULT_SIGNED_BY="$2"
            shift 2
            ;;
        *)
            if [[ -z "$INPUT_FILE" ]]; then
                INPUT_FILE="$1"
            elif [[ -z "$OUTPUT_FILE" ]]; then
                OUTPUT_FILE="$1"
            else
                echo "错误：未知参数 '$1'" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# 验证输入参数
if [[ -z "$INPUT_FILE" || -z "$OUTPUT_FILE" ]]; then
    echo "用法：$0 [--default-signed-by KEYFILE] 输入文件 输出文件" >&2
    exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "错误：输入文件 '$INPUT_FILE' 不存在" >&2
    exit 1
fi

: > "$OUTPUT_FILE" # 清空输出文件

# 主处理循环
while IFS= read -r line; do
    # 清理输入行
    cleaned=$(echo "$line" | sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    [[ -z "$cleaned" ]] && continue

    # 解析基本结构
    if [[ $cleaned =~ ^(deb|deb-src)[[:space:]]+(.*)$ ]]; then
        type=${BASH_REMATCH[1]}
        rest=${BASH_REMATCH[2]}

        # 提取选项部分
        options=""
        if [[ $rest =~ ^\[([^]]+)\][[:space:]]+(.*)$ ]]; then
            options=${BASH_REMATCH[1]}
            rest=${BASH_REMATCH[2]}
        fi

        # 解析URI、套件和组件
        if [[ $rest =~ ^([^[:space:]]+)[[:space:]]+([^[:space:]]+)([[:space:]]+(.*))?$ ]]; then
            uri=${BASH_REMATCH[1]}
            suite=${BASH_REMATCH[2]}
            components=${BASH_REMATCH[4]}
        else
            echo "解析失败：$cleaned" >&2
            exit 1
        fi

        # 处理signed-by选项
        signed_by=""
        if [[ -n "$options" ]]; then
            IFS=' ' read -ra opts <<< "$options"
            for opt in "${opts[@]}"; do
                [[ $opt == signed-by=* ]] && signed_by="${opt#signed-by=}"
            done
        fi

        # 处理未找到签名的情况
        if [[ -z "$signed_by" ]]; then
            if [[ -n "$DEFAULT_SIGNED_BY" ]]; then
                signed_by="$DEFAULT_SIGNED_BY"
            else
                echo "错误：缺少signed-by信息（行：$cleaned）" >&2
                exit 1
            fi
        fi

        # 写入Deb822格式
        {
            echo "Types: $type"
            echo "URIs: $uri"
            echo "Suites: $suite"
            [[ -n "$components" ]] && echo "Components: $components"
            echo "Signed-By: $signed_by"
            echo ""
        } >> "$OUTPUT_FILE"

    else
        echo "警告：跳过无效行 - $cleaned" >&2
    fi
done < "$INPUT_FILE"

echo "转换成功完成！结果保存在：$OUTPUT_FILE"