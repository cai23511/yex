#!/bin/bash
# Display SafeLine ASCII Art Logo
echo "
  ____             __          _       _
 / ___|    __ _   / _|   ___  | |     (_)  _ __     ___
 \___ \   / _\` | | |_   / _ \ | |     | | | '_ \   / _ \\
  ___) | | (_| | |  _| |  __/ | |___  | | | | | | |  __/
 |____/   \__,_| |_|    \___| |_____| |_| |_| |_|  \___|
"

ARCH=$(uname -m)
SAFELINE_PATH="/data/safeline"
RESOLV_CONF="/etc/resolv.conf"
COMPOSE_CMD="docker compose"

# Display QR code function
qrcode() {
    echo "█████████████████████████████████████████"
    echo "█████████████████████████████████████████"
    echo "████ ▄▄▄▄▄ █▀ █▀▀██▀▄▀▀▄▀▄▀▄██ ▄▄▄▄▄ ████"
    echo "████ █   █ █▀ ▄ █▀▄▄▀▀ ▄█▄  ▀█ █   █ ████"
    echo "████ █▄▄▄█ █▀█ █▄█▄▀▀▄▀▄ ▀▀▄▄█ █▄▄▄█ ████"
    echo "████▄▄▄▄▄▄▄█▄█▄█ █▄▀ █ ▀▄▀ █▄█▄▄▄▄▄▄▄████"
    echo "████▄ ▄▄ █▄▄  ▄█▄▄▄▄▀▄▀▀▄██ ▄▄▀▄█▄▀ ▀████"
    echo "████▄ ▄▀▄ ▄▀▄ ▀ ▄█▀ ▀▄ █▀▀ ▀█▀▄██▄▀▄█████"
    echo "█████ ▀▄█ ▄ ▄▄▀▄▀▀█▄▀▄▄▀▄▀▄ ▄ ▀▄▄▄█▀▀████"
    echo "████ █▀▄▀ ▄▀▄▄▀█▀ ▄▄ █▄█▀▀▄▀▀█▄█▄█▀▄█████"
    echo "████ █ ▀  ▄▀▀ ██▄█▄▄▄▄▄▀▄▀▀▀▄▄▀█▄▀█ ▀████"
    echo "████ █ ▀▄ ▄██▀▀ ▄█▀ ▀███▄  ▀▄▀▄▄ ▄▀▄█████"
    echo "████▀▄▄█  ▄▀▄▀ ▄▀▀▀▄▀▄▀ ▄▀▄  ▄▀ ▄▀█ ▀████"
    echo "████ █ █ █▄▀ █▄█▀ ▄▄███▀▀▀▄█▀▄ ▀  ▀▄█████"
    echo "████▄███▄█▄▄▀▄ █▄█▄▄▄▄▀▀▄█▀▀ ▄▄▄  ▀█ ████"
    echo "████ ▄▄▄▄▄ █▄▀█ ▄█▀▄ █▀█▄ ▀  █▄█  ▀▄▀████"
    echo "████ █   █ █  █▄▀▀▀▄▄▄▀▀▀▀▀▀ ▄▄  ▀█  ████"
    echo "████ █▄▄▄█ █  ▀█▀ ▄▄▄▄ ▀█ ▀▀▄▀ ▀▀ ▀██████"
    echo "████▄▄▄▄▄▄▄█▄▄██▄█▄▄█▄██▄██▄▄█▄▄█▄█▄█████"
    echo "█████████████████████████████████████████"
    echo "█████████████████████████████████████████"

    echo
    echo "微信扫描上方二维码加入雷池项目讨论组"
}

# 设置频道版本
RELEASE="${RELEASE}"
# 如果用户提供了 RELEASE 值，则在前面加上 "-"
if [ -n "$RELEASE" ]; then
    RELEASE="-$RELEASE"
fi

# Display messages
info() {
   echo -e "\033[32m[SafeLine] $*\033[0m"
}

warning() {
    echo -e "\033[33m[SafeLine] $*\033[0m"
}

abort() {
    qrcode
    echo -e "\033[31m[SafeLine] $*\033[0m"
    exit 1
}

# Confirm with user (Y/n)
confirm() {
    echo -e -n "\033[34m[SafeLine] $* \033[1;36m(Y/n)\033[0m"
    read -n 1 -s opt
    [[ "$opt" == $'\n' ]] || echo
    case "$opt" in
        y|Y) return 0 ;;
        n|N) return 1 ;;
        *) confirm "$1" ;;
    esac
}

# Check for required commands
command_exists() { command -v "$1" &> /dev/null; }

# Check for SSSE3 instruction support (skip on arm/aarch)
check_ssse3() {
    [[ "$ARCH" =~ "aarch" || "$ARCH" =~ "arm" ]] && return 0
    lscpu | grep -q ssse3 || cat /proc/cpuinfo | grep -q ssse3 || \
    abort "雷池需要支持 SSSE3 指令集的 CPU"
}

get_average_delay() {
    local source=$1
    local total_delay=0
    local iterations=3

    for ((i = 0; i < iterations; i++)); do
        # check timeout
        if ! curl -o /dev/null -m 1 -s -w "%{http_code}\n" "$source" > /dev/null; then
            delay=999
        else
            delay=$(curl -o /dev/null -s -w "%{time_total}\n" "$source")
        fi
        total_delay=$(awk "BEGIN {print $total_delay + $delay}")
    done

    average_delay=$(awk "BEGIN {print $total_delay / $iterations}")
    echo "$average_delay"
}

# Install Docker if needed
install_docker() {
    info "正在安装 Docker..."
    curl -fsSL https://waf-ce.chaitin.cn/release/latest/get-docker.sh -o get-docker.sh
    sources=(
        "https://mirrors.aliyun.com/docker-ce"
        "https://mirrors.tencent.com/docker-ce"
        "https://download.docker.com"
    )
    min_delay=${#sources[@]}
    selected_source=""
    for source in "${sources[@]}"; do
        average_delay=$(get_average_delay "$source")
        echo "source: $source, delay: $average_delay"
        if (( $(awk 'BEGIN { print '"$average_delay"' < '"$min_delay"' }') )); then
            min_delay=$average_delay
            selected_source=$source
        fi
    done

    echo "Docker 源: $selected_source"
    export DOWNLOAD_URL="$selected_source"
    bash get-docker.sh && start_docker
    command_exists docker || abort "Docker 安装失败, 请检查网络连接或手动安装 Docker"
    info "Docker 安装成功"
}

# Start Docker service
start_docker() {
    systemctl enable docker
    systemctl daemon-reload
    systemctl restart docker || abort "Docker 服务启动失败"
}

# Check Docker Compose availability
check_docker_compose() {
    $COMPOSE_CMD version || {
        COMPOSE_CMD="docker-compose"
        $COMPOSE_CMD version || install_docker
    }
}

# Check firewalld and SELinux
check_firewall_selinux() {
    if systemctl is-active --quiet firewalld; then
        warning "检测到 firewalld 正在运行"
        confirm "建议关闭 firewalld，避免网络问题" && systemctl stop firewalld && systemctl disable firewalld
    fi
    # check ufw
    if command_exists ufw && ufw status | grep -q 'active'; then
        warning "检测到 ufw 正在运行"
        confirm "建议关闭 ufw" && ufw disable
    fi
    if grep -q '^SELINUX=enforcing' /etc/selinux/config; then
        warning "检测到 SELinux 正在运行"
        confirm "建议关闭 SELinux" && setenforce 0 && sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config && \
        abort "SELinux 已关闭，请重启系统生效"
    fi
}

# Validate directory path and check space
validate_directory() {
    while true; do
        echo -e -n "\033[34m[SafeLine] 雷池安装目录 (留空则为 '$SAFELINE_PATH'): \033[0m"
        read input_path
        [[ -z "$input_path" ]] && input_path=$SAFELINE_PATH
        [[ "$input_path" == /* ]] || { warning "'$input_path' 不是绝对路径"; continue; }
        [ -e "$input_path" ] && { warning "'$input_path' 已存在"; continue; }
        SAFELINE_PATH=$input_path
        mkdir -p "$SAFELINE_PATH" || { warning "无法创建目录 '$SAFELINE_PATH'"; continue; }
        confirm "目录 '$SAFELINE_PATH' 当前剩余空间: $(df -h "$SAFELINE_PATH" --output='avail' | tail -1)，是否确定" && break
    done
    mkdir -p "$SAFELINE_PATH" || abort "创建安装目录失败"
    info "创建安装目录 '$SAFELINE_PATH' 成功"
}

# 获取平均延迟
get_average_delay() {
    local source=$1
    local total_delay=0
    local iterations=3

    for ((i = 0; i < iterations; i++)); do
        # 检查超时
        if ! curl -o /dev/null -m 1 -s -w "%{http_code}\n" "$source" > /dev/null; then
            delay=999  # 如果连接失败，将延迟设置为 999
        else
            delay=$(curl -o /dev/null -s -w "%{time_total}\n" "$source")  # 获取总时间
        fi
        total_delay=$(awk "BEGIN {print $total_delay + $delay}")
    done

    average_delay=$(awk "BEGIN {print $total_delay / $iterations}")
    echo "$average_delay"
}

# 选择最佳的镜像源
choose_best_image_source() {
    sources=("https://registry-1.docker.io" "https://swr.cn-east-3.myhuaweicloud.com")
    best_source=""
    lowest_delay=999  # 初始为一个很大的延迟值

    for source in "${sources[@]}"; do
        delay=$(get_average_delay "$source")

        if (( $(awk 'BEGIN {print '"$delay"' < '"$lowest_delay"' }') )); then
            lowest_delay=$delay
            best_source=$source
        fi
    done

    if [ -z "$best_source" ]; then
        abort "无法连接到任何镜像源"
    fi

    if [ "$best_source" == "https://registry-1.docker.io" ]; then
        image_prefix="chaitin"
    fi
    if [ "$best_source" == "https://swr.cn-east-3.myhuaweicloud.com" ]; then
        image_prefix="swr.cn-east-3.myhuaweicloud.com/chaitin-safeline"
    fi

    echo "$image_prefix"
}

# Download and set up SafeLine files
setup_safeline_files() {
    cd "$SAFELINE_PATH" || exit
    info "正在下载 compose.yaml 脚本..."
    curl -4sSLk https://waf-ce.chaitin.cn/release/latest/compose.yaml -o compose.yaml || abort "下载 compose.yaml 脚本失败"
    info "正在下载 reset_tengine.sh 脚本..."
    curl -4sSLk https://waf-ce.chaitin.cn/release/latest/reset_tengine.sh -o reset_tengine.sh || abort "下载 reset_tengine.sh 脚本失败"

    # 选择最合适的镜像源
    IMAGE_PREFIX=$(choose_best_image_source)
    info "镜像源: $IMAGE_PREFIX"

    cat <<EOF > .env
SAFELINE_DIR=$SAFELINE_PATH
IMAGE_TAG=latest
MGT_PORT=9444
POSTGRES_PASSWORD=$(LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 32)
SUBNET_PREFIX=172.22.222
ARCH_SUFFIX=$([[ "$ARCH" =~ "aarch" || "$ARCH" =~ "arm" ]] && echo "-arm" || echo "")
IMAGE_PREFIX=$IMAGE_PREFIX
RELEASE=$RELEASE
EOF
    info "配置 .env 文件完成"
}

# Run Docker Compose and validate container health
run_compose() {
    info "正在拉取雷池镜像..."
    $COMPOSE_CMD pull || abort "拉取 Docker 镜像失败"
    info "正在启动雷池服务..."
    $COMPOSE_CMD up -d --remove-orphans || abort "启动 Docker 容器失败"
    for service in safeline-pg safeline-mgt; do
        retry=0
        until docker inspect --format='{{.State.Health.Status}}' $service 2>/dev/null | grep -q "healthy" || ((retry++ > 30)); do
            sleep 5
        done
        [[ $retry -gt 30 ]] && abort "$service 容器未正常启动"
    done
    info "雷池服务启动成功"
}

# Main script execution
check_firewall_selinux
check_ssse3
command_exists docker || install_docker
check_docker_compose
validate_directory
setup_safeline_files
run_compose
qrcode

docker exec safeline-mgt /app/mgt-cli reset-admin --once

# Display final access URLs
info "雷池 WAF 社区版安装成功，请访问以下地址访问控制台"
for ip in $(hostname -I); do
    warning "https://$ip:9444/"
done
