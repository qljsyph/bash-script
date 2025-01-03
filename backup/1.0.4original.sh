#!/bin/bash

# 检查 bc 命令
check_bc_installed() {
    if ! command -v bc &> /dev/null; then
        echo "bc 命令未安装，正在尝试安装..."

        # 检查操作系统并选择安装命令
        if [ -f /etc/debian_version ]; then
            sudo apt update && sudo apt install -y bc
        else
            echo "不支持的操作系统，请手动安装 bc 后重试。"
            exit 1
        fi

        # 再次检查 bc 是否安装成功
        if ! command -v bc &> /dev/null; then
            echo "安装 bc 失败，请检查网络或包管理器配置。"
            exit 1
        fi

        echo "bc 已成功安装。"
    else
        echo "bc 已安装，继续执行脚本。"
    fi
}

# 检查的代码块
check_code='if [ -n "$SSH_CONNECTION" ]; then
 run-parts /etc/update-motd.d
fi'

# 精确检查代码块是否存在（忽略空白和换行）
check_code_exists() {
    local normalized_file=$(grep -v '^\s*$' /etc/profile | tr -d '[:space:]')
    local normalized_code=$(echo "$1" | tr -d '[:space:]')

    if [[ "$normalized_file" == *"$normalized_code"* ]]; then
        return 0  # 找到完全匹配
    else
        return 1  # 未找到匹配
    fi
}

# 下载并设置 MOTD 脚本
download_motd_script() {
    # 选择操作系统类型：Debian 或 Armbian
    read -p "请选择操作系统类型 (输入debian/armbian/回车退出): " os_type
    os_type=${os_type,,} # 转换为小写

    # 根据操作系统类型选择下载的文件
    if [ "$os_type" == "debian" ]; then
        # 删除已有文件并下载新的文件
        for file_name in "20-debian-sysinfo" "00-debian-heads"; do
            file_dest="/etc/update-motd.d/$file_name"
            if [ -f "$file_dest" ]; then
                echo "文件 $file_name 已存在，删除旧文件并重新下载..."
                sudo rm -f "$file_dest"
            fi
        done
        
        # 下载两个文件
        file_url_1="https://ghgo.xyz/https://raw.githubusercontent.com/qljsyph/bash-script/refs/heads/main/sysinfo/20-debian-sysinfo"
        file_url_2="https://ghgo.xyz/https://raw.githubusercontent.com/qljsyph/bash-script/refs/heads/main/sysinfo/00-debian-heads"
        
        curl -s -o "/etc/update-motd.d/20-debian-sysinfo" "$file_url_1"
        curl -s -o "/etc/update-motd.d/00-debian-heads" "$file_url_2"
        
        # 检查下载是否成功
        if [ $? -eq 0 ]; then
            chmod 755 /etc/update-motd.d/{20-debian-sysinfo,00-debian-heads}
            echo "Debian 文件已成功下载并设置权限为 755。"
        else
            echo "文件下载失败! 错误信息：$?"
            exit 1
        fi
    elif [ "$os_type" == "armbian" ]; then
        file_url="https://ghgo.xyz/https://raw.githubusercontent.com/qljsyph/bash-script/refs/heads/main/sysinfo/20-armbian-sysinfo2"
        file_name="20-armbian-sysinfo"

        # 删除已有文件并下载新的文件
        file_dest="/etc/update-motd.d/$file_name"
        if [ -f "$file_dest" ]; then
            echo "文件 $file_name 已存在，删除旧文件并重新下载..."
            sudo rm -f "$file_dest"
        fi
        
        echo "正在从 GitHub 下载 Armbian 文件..."
        curl -s -o "$file_dest" "$file_url"

        # 检查下载是否成功
        if [ $? -eq 0 ]; then
            chmod 755 "$file_dest"
            echo "Armbian 文件已成功下载并设置权限为 755。"
        else
            echo "文件下载失败! 错误信息：$?"
            exit 1
        fi
    else
        echo "无效的操作系统类型，退出脚本。"
        exit 1
    fi

    # 检查下载的脚本是否依赖 bc
    if grep -q "bc" "$file_dest"; then
        echo "检测到 MOTD 脚本使用了 bc，确保其已正确安装..."
        check_bc_installed
    fi
}

# 主脚本逻辑
main() {
    # 检查是否安装了 bc
    check_bc_installed

    # 检查并添加代码块到 /etc/profile
    if ! check_code_exists "$check_code"; then
        echo "未找到完全匹配的代码块，准备添加..."

        # 先检查是否已经存在相似的代码块
        existing_count=$(grep -c "run-parts /etc/update-motd.d" /etc/profile)

        if [ "$existing_count" -gt 0 ]; then
            echo "警告：已存在类似的代码块（$existing_count 处）"
            echo "请手动检查 /etc/profile 文件中是否需要去重"
            exit 1
        fi

        # 确保文件以换行结尾
        sudo sed -i -e '$a\\' /etc/profile

        # 追加代码块
        echo "$check_code" | sudo tee -a /etc/profile > /dev/null

        echo "代码块已成功添加到 /etc/profile"
    else
        echo "完整的代码块已存在于 /etc/profile，跳过添加"
    fi

    # 执行下载 MOTD 脚本
    download_motd_script
}

# 运行主脚本
main
