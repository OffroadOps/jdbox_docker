#!/bin/bash
# Source: https://github.com/OffroadOps/jdbox_docker
# Updated: 2025-03-05

# 日志文件
LOG_FILE="./jd_container_setup.log"
> "$LOG_FILE"

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 输出日志
function log() {
    message="[Install Log]: $1"
    echo -e "${GREEN}$message${NC}" | tee -a "$LOG_FILE"
}

# 输出错误警告
function warn() {
    message="[警告]: $1"
    echo -e "${RED}$message${NC}" | tee -a "$LOG_FILE"
}

# 显示菜单
function show_menu() {
    clear
    echo -e "${GREEN}京东云容器矩阵  一键脚本"
    echo -e "----------- By zhazhahui -----------${NC}"
    echo -e "----https://github.com/OffroadOps/jdbox_docker---${NC}"
    echo "1. 安装 矩阵"
    echo "2. 更新 矩阵"
    echo "3. 卸载 矩阵"
    echo "4. 换机安装"
    echo "——————————————"
    echo "5. 启动 矩阵"
    echo "6. 停止 矩阵"
    echo "7. 重启 矩阵"
    echo "8. 修改 激活码"
    echo "9. 修改 硬盘路径"
    echo "10. 安装 Docker"
    echo "0. 退出脚本"
    echo "——————————————"
}

# **检查 Docker 是否安装**
function check_docker() {
    if ! command -v docker &>/dev/null; then
        warn "Docker 未安装，正在安装 Docker..."
        install_docker
    else
        log "Docker 已安装，继续执行"
    fi
}

# **安装 Docker**
function install_docker() {
    log "安装 Docker..."
    curl -fsSL https://get.docker.com | bash
    systemctl enable docker
    systemctl start docker
    log "Docker 安装成功"
}

# **安装 矩阵**
function install_matrix() {
    log "安装 矩阵"
    read -p "请输入授权码: " activation_code

    docker login cmatrix.jdbox.xyz:36534 --username robot\$cmatrix --password-stdin <<< "WcRTh0OG6pLeWdMM7XyJ3DqfxC4opToo"
    if [ $? -ne 0 ]; then
        warn "Docker 登录失败，请检查授权码或网络连接"
        exit 1
    fi

    docker run -d -it --name cmatrix --net=host --privileged -e ACTIVECODE="$activation_code" cmatrix.jdbox.xyz:36534/cmatrix/cmatrix:latest
    log "矩阵安装完成！"
    exit 0  # 直接退出，避免返回菜单
}

# **更新 矩阵**
function update_matrix() {
    log "更新 矩阵"
    docker pull cmatrix.jdbox.xyz:36534/cmatrix/cmatrix:latest
    docker stop cmatrix && docker rm cmatrix
    install_matrix
}

# **卸载 矩阵**
function uninstall_matrix() {
    warn "正在卸载 矩阵..."
    docker stop cmatrix && docker rm cmatrix
    docker rmi cmatrix.jdbox.xyz:36534/cmatrix/cmatrix:latest
    log "矩阵 已卸载"
}

# **换机安装**
function change_machine_installation() {
    warn "换机安装将删除现有实例，是否继续？(Y/N)"
    read -p "请输入 (Y/N): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        uninstall_matrix
        install_matrix
    else
        log "已取消换机安装"
    fi
}

# **启动 矩阵**
function start_matrix() {
    log "启动 矩阵"
    docker start cmatrix
}

# **停止 矩阵**
function stop_matrix() {
    log "停止 矩阵"
    docker stop cmatrix
}

# **重启 矩阵**
function restart_matrix() {
    log "重启 矩阵"
    docker restart cmatrix
}

# **修改 激活码**
function modify_activation_code() {
    read -p "请输入新的授权码: " new_code
    docker stop cmatrix
    docker rm cmatrix
    install_matrix "$new_code"
}

# **修改 硬盘路径**
function modify_disk_path() {
    read -p "请输入新的存储路径: " new_path
    docker stop cmatrix
    docker rm cmatrix
    docker run -d -it --name cmatrix --net=host --privileged -v "$new_path:/data" cmatrix.jdbox.xyz:36534/cmatrix/cmatrix:latest
    log "存储路径已修改"
}

# **选择操作**
function choose_option() {
    read -p "请输入数字 [0-10]: " choice
    case $choice in
        1) install_matrix ;;
        2) update_matrix ;;
        3) uninstall_matrix ;;
        4) change_machine_installation ;;
        5) start_matrix ;;
        6) stop_matrix ;;
        7) restart_matrix ;;
        8) modify_activation_code ;;
        9) modify_disk_path ;;
        10) install_docker ;;
        0) exit 0 ;;
        *) warn "无效选项，请重新输入" && sleep 1 ;;
    esac
}

# **主程序**
function main() {
    check_docker
    while true; do
        show_menu
        choose_option
    done
}

# **启动主程序**
main
