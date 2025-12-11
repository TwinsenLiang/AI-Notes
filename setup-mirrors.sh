#!/bin/bash
# 远程 Linux 机器自动化配置脚本
# 用法: ./setup-mirrors.sh user@host [-p port]

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 显示使用方法
usage() {
    echo "用法: $0 <user@host> [-p port]"
    echo ""
    echo "示例:"
    echo "  $0 pi@192.168.1.100"
    echo "  $0 pi@192.168.1.100 -p 2222"
    exit 1
}

# 检查参数
if [ $# -lt 1 ]; then
    usage
fi

TARGET=$1
PORT=""
SSH_PORT_ARG=""

# 解析端口参数
if [ "$2" = "-p" ] && [ -n "$3" ]; then
    PORT="-p $3"
    SSH_PORT_ARG="-p $3"
fi

echo -e "${CYAN}========================================"
echo -e "  远程 Linux 机器自动化配置工具"
echo -e "  目标: $TARGET"
echo -e "========================================${NC}"
echo ""

# 先测试连接
echo -e "${YELLOW}[准备] 测试 SSH 连接...${NC}"
if ! ssh $PORT -o ConnectTimeout=5 $TARGET "echo '连接成功'" 2>/dev/null; then
    echo -e "${RED}❌ SSH 连接失败，请检查：${NC}"
    echo "  1. 目标机器是否在线"
    echo "  2. SSH 服务是否启动"
    echo "  3. 用户名和 IP 是否正确"
    echo "  4. 端口是否正确"
    exit 1
fi
echo -e "${GREEN}✅ SSH 连接成功${NC}"
echo ""

# 获取远程主机信息
echo -e "${YELLOW}[信息] 获取远程主机信息...${NC}"
HOSTNAME=$(ssh $PORT $TARGET "hostname" 2>/dev/null)
OS_INFO=$(ssh $PORT $TARGET "cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"'" 2>/dev/null)
echo -e "${GREEN}主机名: $HOSTNAME${NC}"
echo -e "${GREEN}系统: $OS_INFO${NC}"
echo ""

# ============================================
# 配置菜单
# ============================================

echo -e "${CYAN}请选择要执行的配置步骤（多选，用空格分隔）：${NC}"
echo ""
echo "  1) SSH 免密登录配置 (ssh-copy-id)"
echo "  2) 安装 zsh 和 oh-my-zsh"
echo "  3) 配置 APT 镜像源（清华大学）"
echo "  4) 配置 NPM 镜像源（淘宝）"
echo "  5) 配置 PIP 镜像源（清华大学）"
echo "  6) 安装常用工具 (vim, curl, wget, git, htop)"
echo "  7) 配置 Git 用户信息"
echo "  8) 设置时区为 Asia/Shanghai"
echo "  9) 安装 AI CLI 工具 (Claude Code, Qoder CLI, CodeBuddy)"
echo ""
echo "  a) 全部执行"
echo "  q) 退出"
echo ""
read -p "请输入选项（如: 1 3 4 或 a）: " choices

# 如果选择全部执行
if [[ "$choices" == "a" ]]; then
    choices="1 2 3 4 5 6 7 8 9"
fi

# 如果选择退出
if [[ "$choices" == "q" ]]; then
    echo "退出配置"
    exit 0
fi

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  开始执行配置...${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# ============================================
# 1. SSH 免密登录配置
# ============================================

if [[ "$choices" =~ "1" ]]; then
    echo -e "${YELLOW}[1/8] 配置 SSH 免密登录...${NC}"

    # 检查本地是否有 SSH 密钥
    if [ ! -f ~/.ssh/id_rsa.pub ] && [ ! -f ~/.ssh/id_ed25519.pub ]; then
        echo "本地没有 SSH 密钥，正在生成..."
        read -p "请输入邮箱（用于 SSH 密钥标识）: " email
        ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519 -N ""
        echo -e "${GREEN}✅ SSH 密钥已生成${NC}"
    fi

    # 复制公钥到远程主机
    echo "正在复制公钥到远程主机..."
    if [ -f ~/.ssh/id_ed25519.pub ]; then
        ssh-copy-id $SSH_PORT_ARG -i ~/.ssh/id_ed25519.pub $TARGET
    elif [ -f ~/.ssh/id_rsa.pub ]; then
        ssh-copy-id $SSH_PORT_ARG -i ~/.ssh/id_rsa.pub $TARGET
    fi

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ SSH 免密登录配置完成${NC}"
        echo "测试免密登录..."
        if ssh $PORT -o BatchMode=yes -o ConnectTimeout=5 $TARGET "echo '免密登录成功'" 2>/dev/null; then
            echo -e "${GREEN}✅ 免密登录测试成功${NC}"
        else
            echo -e "${YELLOW}⚠️  免密登录测试失败，但密钥可能已复制${NC}"
        fi
    else
        echo -e "${RED}❌ SSH 免密登录配置失败${NC}"
    fi
    echo ""
fi

# ============================================
# 2. 安装 zsh 和 oh-my-zsh
# ============================================

if [[ "$choices" =~ "2" ]]; then
    echo -e "${YELLOW}[2/8] 安装 zsh 和 oh-my-zsh...${NC}"

    ssh $PORT $TARGET 'bash -s' << 'ENDSSH'
# 检查 zsh 是否已安装
if command -v zsh &> /dev/null; then
    echo "✅ zsh 已安装: $(zsh --version)"
else
    echo "正在安装 zsh..."
    sudo apt update -qq
    sudo apt install -y zsh

    if [ $? -eq 0 ]; then
        echo "✅ zsh 安装成功: $(zsh --version)"
    else
        echo "❌ zsh 安装失败"
        exit 1
    fi
fi

# 检查 oh-my-zsh 是否已安装
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "✅ oh-my-zsh 已安装"
else
    echo "正在安装 oh-my-zsh..."

    # 使用国内镜像安装 oh-my-zsh
    export REMOTE=https://gitee.com/mirrors/oh-my-zsh.git
    INSTALL_OUTPUT=$(sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)" "" --unattended 2>&1)
    INSTALL_STATUS=$?

    if [ $INSTALL_STATUS -eq 0 ] && [ -d "$HOME/.oh-my-zsh" ]; then
        echo "✅ oh-my-zsh 安装成功（Gitee 镜像）"
    else
        echo "⚠️  Gitee 镜像安装失败，尝试使用官方源..."
        INSTALL_OUTPUT=$(sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>&1)
        INSTALL_STATUS=$?

        if [ $INSTALL_STATUS -eq 0 ] && [ -d "$HOME/.oh-my-zsh" ]; then
            echo "✅ oh-my-zsh 安装成功（官方源）"
        else
            echo "❌ oh-my-zsh 安装失败"
            echo "错误信息: $INSTALL_OUTPUT"
            exit 1
        fi
    fi
fi

# 验证 oh-my-zsh 安装
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "❌ 错误: oh-my-zsh 目录不存在"
    exit 1
fi

if [ ! -f "$HOME/.zshrc" ]; then
    echo "❌ 错误: .zshrc 配置文件不存在"
    exit 1
fi

echo "✅ oh-my-zsh 核心文件验证通过"

# 安装常用插件
echo "正在安装 oh-my-zsh 插件..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# zsh-autosuggestions
if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "  ✓ zsh-autosuggestions 已安装"
else
    echo "  正在安装 zsh-autosuggestions..."
    if git clone https://gitee.com/hailin_cool/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions 2>/dev/null; then
        echo "  ✓ zsh-autosuggestions 安装成功（Gitee）"
    elif git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions 2>/dev/null; then
        echo "  ✓ zsh-autosuggestions 安装成功（GitHub）"
    else
        echo "  ⚠️  zsh-autosuggestions 安装失败"
    fi
fi

# zsh-syntax-highlighting
if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "  ✓ zsh-syntax-highlighting 已安装"
else
    echo "  正在安装 zsh-syntax-highlighting..."
    if git clone https://gitee.com/Annihilater/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting 2>/dev/null; then
        echo "  ✓ zsh-syntax-highlighting 安装成功（Gitee）"
    elif git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting 2>/dev/null; then
        echo "  ✓ zsh-syntax-highlighting 安装成功（GitHub）"
    else
        echo "  ⚠️  zsh-syntax-highlighting 安装失败"
    fi
fi

# 启用插件
if [ -f ~/.zshrc ]; then
    # 检查是否已经配置了插件
    if grep -q "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" ~/.zshrc; then
        echo "✅ 插件已配置"
    else
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
        echo "✅ 插件配置完成"
    fi
fi

# 检查当前默认 shell
CURRENT_SHELL=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
ZSH_PATH=$(which zsh)

echo ""
echo "================================"
echo "当前默认 shell: $CURRENT_SHELL"
echo "zsh 路径: $ZSH_PATH"

if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    echo ""
    echo "注意: 当前默认 shell 不是 zsh"
    echo "如需将 zsh 设为默认 shell，请运行："
    echo "  chsh -s $ZSH_PATH"
    echo ""
    echo "然后重新登录生效"
else
    echo "✅ 默认 shell 已经是 zsh"
fi
echo "================================"
ENDSSH

    REMOTE_STATUS=$?

    if [ $REMOTE_STATUS -eq 0 ]; then
        echo -e "${GREEN}✅ zsh 和 oh-my-zsh 安装配置完成${NC}"
        echo ""

        # 询问是否切换默认 shell
        echo -e "${CYAN}是否将 zsh 设为默认 shell？${NC}"
        read -p "输入 y 确认（需要输入密码）: " switch_shell

        if [[ "$switch_shell" == "y" || "$switch_shell" == "Y" ]]; then
            echo "正在切换默认 shell 到 zsh..."
            ssh $PORT $TARGET "chsh -s \$(which zsh)"

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ 默认 shell 已切换为 zsh${NC}"
                echo -e "${YELLOW}⚠️  请重新登录以使更改生效${NC}"
            else
                echo -e "${RED}❌ 切换 shell 失败${NC}"
            fi
        else
            echo "跳过切换默认 shell"
        fi
    else
        echo -e "${RED}❌ zsh 和 oh-my-zsh 安装失败${NC}"
    fi
    echo ""
fi

# ============================================
# 3. 配置 APT 镜像源
# ============================================

if [[ "$choices" =~ "3" ]]; then
    echo -e "${YELLOW}[3/8] 配置 APT 镜像源（清华大学）...${NC}"

    ssh $PORT $TARGET 'bash -s' << 'ENDSSH'
# 检测系统版本
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION_CODENAME=$VERSION_CODENAME
else
    echo "无法检测系统版本"
    exit 1
fi

# 备份原有源
if [ ! -f /etc/apt/sources.list.bak ]; then
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    echo "已备份原有 APT 源到 /etc/apt/sources.list.bak"
fi

# 根据系统配置镜像源
if [ "$OS" = "ubuntu" ]; then
    # Ubuntu 清华源
    sudo tee /etc/apt/sources.list > /dev/null << EOF
# 清华大学镜像源
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $VERSION_CODENAME main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $VERSION_CODENAME-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $VERSION_CODENAME-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $VERSION_CODENAME-security main restricted universe multiverse
EOF
    echo "✅ 已配置 Ubuntu 清华镜像源"
elif [ "$OS" = "debian" ] || [ "$OS" = "raspbian" ]; then
    # Debian/Raspbian 清华源
    sudo tee /etc/apt/sources.list > /dev/null << EOF
# 清华大学镜像源
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ $VERSION_CODENAME main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ $VERSION_CODENAME-updates main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ $VERSION_CODENAME-backports main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security $VERSION_CODENAME-security main contrib non-free
EOF
    echo "✅ 已配置 Debian/Raspbian 清华镜像源"
else
    echo "⚠️  未识别的系统: $OS，跳过 APT 配置"
fi

# 更新软件包列表
echo "更新软件包列表..."
sudo apt update -qq
ENDSSH

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ APT 镜像源配置完成${NC}"
    else
        echo -e "${RED}❌ APT 镜像源配置失败${NC}"
    fi
    echo ""
fi

# ============================================
# 4. 配置 NPM 镜像源
# ============================================

if [[ "$choices" =~ "4" ]]; then
    echo -e "${YELLOW}[4/8] 配置 NPM 镜像源（淘宝）...${NC}"

    ssh $PORT $TARGET 'bash -s' << 'ENDSSH'
# 检查 npm 是否安装
if command -v npm &> /dev/null; then
    # 配置淘宝镜像
    npm config set registry https://registry.npmmirror.com
    echo "✅ 已配置 NPM 淘宝镜像源"
    echo "当前 NPM 源: $(npm config get registry)"
else
    echo "⚠️  NPM 未安装，跳过配置"
fi
ENDSSH

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ NPM 镜像源配置完成${NC}"
    else
        echo -e "${RED}❌ NPM 镜像源配置失败${NC}"
    fi
    echo ""
fi

# ============================================
# 5. 配置 PIP 镜像源
# ============================================

if [[ "$choices" =~ "5" ]]; then
    echo -e "${YELLOW}[5/8] 配置 PIP 镜像源（清华大学）...${NC}"

    ssh $PORT $TARGET 'bash -s' << 'ENDSSH'
# 检查 pip 是否安装
if command -v pip3 &> /dev/null || command -v pip &> /dev/null; then
    # 创建 pip 配置目录
    mkdir -p ~/.pip

    # 配置清华镜像
    cat > ~/.pip/pip.conf << EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF
    echo "✅ 已配置 PIP 清华镜像源"
    echo "配置文件位置: ~/.pip/pip.conf"
else
    echo "⚠️  PIP 未安装，跳过配置"
fi
ENDSSH

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ PIP 镜像源配置完成${NC}"
    else
        echo -e "${RED}❌ PIP 镜像源配置失败${NC}"
    fi
    echo ""
fi

# ============================================
# 6. 安装常用工具
# ============================================

if [[ "$choices" =~ "6" ]]; then
    echo -e "${YELLOW}[6/8] 安装常用工具...${NC}"

    ssh $PORT $TARGET 'bash -s' << 'ENDSSH'
echo "更新软件包列表..."
sudo apt update -qq

echo "安装常用工具: vim curl wget git htop tree net-tools..."
sudo apt install -y vim curl wget git htop tree net-tools

if [ $? -eq 0 ]; then
    echo "✅ 常用工具安装完成"
else
    echo "❌ 部分工具安装失败"
fi
ENDSSH

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 常用工具安装完成${NC}"
    else
        echo -e "${RED}❌ 常用工具安装失败${NC}"
    fi
    echo ""
fi

# ============================================
# 7. 配置 Git 用户信息
# ============================================

if [[ "$choices" =~ "7" ]]; then
    echo -e "${YELLOW}[7/8] 配置 Git 用户信息...${NC}"

    read -p "请输入 Git 用户名: " git_username
    read -p "请输入 Git 邮箱: " git_email

    ssh $PORT $TARGET "bash -s" << ENDSSH
# 配置 Git 用户信息
git config --global user.name "$git_username"
git config --global user.email "$git_email"

# 配置 Git 别名
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

echo "✅ Git 配置完成"
echo "用户名: $git_username"
echo "邮箱: $git_email"
ENDSSH

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Git 用户信息配置完成${NC}"
    else
        echo -e "${RED}❌ Git 用户信息配置失败${NC}"
    fi
    echo ""
fi

# ============================================
# 8. 设置时区
# ============================================

if [[ "$choices" =~ "8" ]]; then
    echo -e "${YELLOW}[8/8] 设置时区为 Asia/Shanghai...${NC}"

    ssh $PORT $TARGET 'bash -s' << 'ENDSSH'
# 设置时区
sudo timedatectl set-timezone Asia/Shanghai

if [ $? -eq 0 ]; then
    echo "✅ 时区设置完成"
    echo "当前时区: $(timedatectl | grep "Time zone" | awk '{print $3}')"
    echo "当前时间: $(date)"
else
    echo "❌ 时区设置失败"
fi
ENDSSH

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 时区设置完成${NC}"
    else
        echo -e "${RED}❌ 时区设置失败${NC}"
    fi
    echo ""
fi

# ============================================
# 9. 安装 AI CLI 工具
# ============================================

if [[ "$choices" =~ "9" ]]; then
    echo -e "${YELLOW}[9/9] 安装 AI CLI 工具...${NC}"

    ssh $PORT $TARGET 'bash -s' << 'ENDSSH'
# 检查 Node.js 是否安装
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装，无法安装 Claude Code 和 CodeBuddy"
    echo "请先运行选项 4 配置 NPM 镜像源，会自动安装 Node.js"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
echo "✅ Node.js 已安装: $(node --version)"

# 检查 Node.js 版本（CodeBuddy 需要 22+）
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "⚠️  Node.js 版本过低 (当前: v$NODE_VERSION)，建议升级到 v18+"
fi

echo ""
echo "================================"
echo "开始安装 AI CLI 工具..."
echo "================================"
echo ""

# 1. 安装 Claude Code
echo "[1/3] 正在安装 Claude Code..."
if command -v claude &> /dev/null; then
    echo "  ✓ Claude Code 已安装: $(claude --version 2>&1 | head -1)"
else
    sudo npm install -g @anthropic-ai/claude-code
    if [ $? -eq 0 ]; then
        echo "  ✅ Claude Code 安装成功"
        echo "  提示: 需要配置 ANTHROPIC_AUTH_TOKEN 才能使用"
        echo "  配置方法: https://docs.aicodewith.com/docs/claude-code/linux"
    else
        echo "  ❌ Claude Code 安装失败"
    fi
fi
echo ""

# 2. 安装 Qoder CLI
echo "[2/3] 正在安装 Qoder CLI..."
if command -v qoder &> /dev/null; then
    echo "  ✓ Qoder CLI 已安装: $(qoder --version 2>&1 | head -1)"
else
    curl -fsSL https://qoder.com/install | bash
    if [ $? -eq 0 ]; then
        echo "  ✅ Qoder CLI 安装成功"
    else
        echo "  ❌ Qoder CLI 安装失败"
    fi
fi
echo ""

# 3. 安装 CodeBuddy
echo "[3/3] 正在安装 CodeBuddy (腾讯云代码助手)..."
if command -v codebuddy &> /dev/null; then
    echo "  ✓ CodeBuddy 已安装: $(codebuddy --version 2>&1 | head -1)"
else
    if [ "$NODE_VERSION" -lt 22 ]; then
        echo "  ⚠️  CodeBuddy 推荐 Node.js 22+，当前版本: v$NODE_VERSION"
        echo "  尝试安装..."
    fi
    sudo npm install -g @tencent-ai/codebuddy-code
    if [ $? -eq 0 ]; then
        echo "  ✅ CodeBuddy 安装成功"
    else
        echo "  ❌ CodeBuddy 安装失败"
    fi
fi
echo ""

# 验证安装
echo "================================"
echo "安装验证:"
echo "================================"
command -v claude &> /dev/null && echo "  ✅ Claude Code: $(which claude)" || echo "  ❌ Claude Code 未找到"
command -v qodercli &> /dev/null && echo "  ✅ Qoder CLI: $(which qodercli)" || echo "  ❌ Qoder CLI 未找到"
command -v codebuddy &> /dev/null && echo "  ✅ CodeBuddy: $(which codebuddy)" || echo "  ❌ CodeBuddy 未找到"
echo ""

# 配置智能别名和函数
echo "================================"
echo "配置智能别名..."
echo "================================"

# 检测当前 shell 配置文件
if [ -f ~/.zshrc ]; then
    SHELL_RC=~/.zshrc
elif [ -f ~/.bashrc ]; then
    SHELL_RC=~/.bashrc
else
    SHELL_RC=~/.bashrc
    touch $SHELL_RC
fi

# 检查是否已经配置过
if grep -q "# AI CLI Tools Aliases" "$SHELL_RC" 2>/dev/null; then
    echo "  ✓ 智能别名已配置"
else
    echo "  正在添加智能别名到 $SHELL_RC..."

    # 添加配置到 shell rc 文件
    cat >> "$SHELL_RC" << 'EOF'

# ============================================
# AI CLI Tools Aliases
# ============================================

# Claude Code 智能启动（有历史则继续，否则新建）
alias claude='claude --continue 2>/dev/null || claude'

# AI 函数 - 支持 -n/--new 参数强制新开会话
function AI() {
    if [[ "$1" == "-n" ]] || [[ "$1" == "--new" ]]; then
        shift
        command claude "$@"
    else
        command claude --continue 2>/dev/null || command claude "$@"
    fi
}

# Qoder CLI 路径配置
export PATH="$PATH:$HOME/.local/bin"

# Qoder CLI 智能启动（有历史则继续，否则新建）
alias qoder='qodercli --continue 2>/dev/null || qodercli'

# Qoder CLI 函数 - 支持 -n/--new 参数强制新开会话
function qo() {
    if [[ "$1" == "-n" ]] || [[ "$1" == "--new" ]]; then
        shift
        qodercli "$@"
    else
        qodercli --continue 2>/dev/null || qodercli "$@"
    fi
}

# CodeBuddy 智能启动（有历史则继续，否则新建）
alias cb-continue='codebuddy --continue 2>/dev/null || codebuddy'

# CodeBuddy CLI 函数 - 支持 -n/--new 参数强制新开会话
function cb() {
    if [[ "$1" == "-n" ]] || [[ "$1" == "--new" ]]; then
        shift
        codebuddy "$@"
    else
        codebuddy --continue 2>/dev/null || codebuddy "$@"
    fi
}

# ============================================
EOF

    if [ $? -eq 0 ]; then
        echo "  ✅ 智能别名配置完成"
        echo "  配置文件: $SHELL_RC"
    else
        echo "  ❌ 智能别名配置失败"
    fi
fi

echo ""
echo "提示:"
echo "  • Claude Code 需要配置 ANTHROPIC_AUTH_TOKEN 环境变量"
echo "  • 使用 'AI' 命令智能启动 Claude (自动继续会话)"
echo "  • 使用 'AI -n' 强制开启新会话"
echo "  • 使用 'qo' 命令智能启动 Qoder CLI"
echo "  • 使用 'cb' 命令智能启动 CodeBuddy"
echo "  • 重新登录或运行 'source $SHELL_RC' 使配置生效"
ENDSSH

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ AI CLI 工具安装完成${NC}"
    else
        echo -e "${RED}❌ AI CLI 工具安装失败${NC}"
    fi
    echo ""
fi

# ============================================
# 完成
# ============================================

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  🎉 配置完成！${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo "配置摘要:"
[[ "$choices" =~ "1" ]] && echo "  ✅ SSH 免密登录"
[[ "$choices" =~ "2" ]] && echo "  ✅ zsh 和 oh-my-zsh"
[[ "$choices" =~ "3" ]] && echo "  ✅ APT 镜像源（清华大学）"
[[ "$choices" =~ "4" ]] && echo "  ✅ NPM 镜像源（淘宝 npmmirror）"
[[ "$choices" =~ "5" ]] && echo "  ✅ PIP 镜像源（清华大学）"
[[ "$choices" =~ "6" ]] && echo "  ✅ 常用工具安装"
[[ "$choices" =~ "7" ]] && echo "  ✅ Git 用户信息配置"
[[ "$choices" =~ "8" ]] && echo "  ✅ 时区设置（Asia/Shanghai）"
[[ "$choices" =~ "9" ]] && echo "  ✅ AI CLI 工具 (Claude Code, Qoder CLI, CodeBuddy)"
echo ""
echo "备注:"
echo "  • 如果安装了 zsh，可运行 'chsh -s \$(which zsh)' 设为默认 shell"
echo "  • APT 原有配置已备份至 /etc/apt/sources.list.bak"
echo "  • 可运行 'apt update' 测试 APT 源是否正常"
echo "  • 可运行 'npm config get registry' 查看 NPM 源"
echo "  • 可运行 'pip config list' 查看 PIP 源"
echo ""
