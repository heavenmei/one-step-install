#!/usr/bin/env bash

declare -a common_packages=(
    curl wget git zsh tmux bat unzip
    silversearcher-ag fonts-powerline lsb_release
)

get_system_kind() {
    if [[ $(uname) == 'Darwin' ]]; then
        echo 'mac'
        return $?
    fi

    if [[ $(uname) == 'Linux' ]]; then
        echo 'linux'
        return $?
    fi
}
get_system_info() {
    if [[ $(uname) == 'Darwin' ]]; then
        if [[ $(uname -m) == "x86_64" ]]; then
            echo "mac_intel"
        else
            echo "mac_arm"
        fi
        return $?
    fi

    if [[ $(uname) == 'Linux' ]]; then
        ubuntu_version=$(lsb_release -rs)
        if [[ $ubuntu_version == "18.04" ]]; then
            echo "ubuntu_18"
        else
            echo "ubuntu"
        fi
        return $?
    fi
}
system_kind=$(get_system_kind)
system_info=$(get_system_info)

# basic packages
install_linux() {
    sudo chmod -R 777 ./

    echo "[*]: apt updating "
    sudo apt upgrade -y
    echo "[*]: apt update done "
    for prog in "${common_packages[@]}"; do
        if command -v "$prog" >/dev/null >&1; then
            echo -e "[*]: $prog installed, skip!"
        else
            sudo apt install -y "$prog" >/dev/null >&1
            if [ $? -eq 0 ]; then
                echo -e "[*]: $prog install success..."
            else
                echo -e "[*]:\033[31m ${prog} install error \033[0m"
            fi
        fi
    done
    # vim 单独安装
    sudo apt install -y vim >/dev/null
    if [ $? -eq 0 ]; then
        echo -e "\033[32;1m[*]: $prog install success! \033[0m"
    else
        echo -e "[*]:\033[31m ${prog} install error \033[0m"
    fi
}
install_mac() {
    if command -v brew >/dev/null >&1; then
        echo -e "[*]: brew installed, skip!"
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        {
            export PATH="/opt/homebrew/sbin:$PATH"
            echo -e '# HomeBrew'
            echo -e 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles'
            echo -e 'export PATH="/opt/homebrew/bin:$PATH" '
            echo -e '# HomeBrew END'
        } >>~/.zshrc

        for prog in "${common_packages[@]}"; do
            if command -v "$prog" >/dev/null >&1; then
                echo -e "[*]: $prog installed, skip!"
            else
                #  arch -arm64 brew install xxx
                brew install -y "$prog" >/dev/null >&1
                if [ $? -eq 0 ]; then
                    echo -e "[*]: $prog install success..."
                else
                    echo -e "[*]:\033[31m ${prog} install error \033[0m"
                fi
            fi
        done
    fi

}
install_basic() {
    echo -e "[*]: Installing packages for $system_kind..."
    case $system_kind in
    linux) install_linux ;;
    mac) install_mac ;;
    *) echo "Unknown system!" && exit 1 ;;
    esac

}

set_ssh_port() {
    SSH_PORT=$(cat /etc/ssh/sshd_config | ag -o '(?<=Port )\d+')
    if [ "$SSH_PORT" -eq 22 ]; then
        echo -e "[*]开始配置随机SSH 端口"
        SSH_NEW_PORT=$(shuf -i 10000-30000 -n1)
        echo -e "\033[33m[!]: SSHD Port: ${SSH_NEW_PORT} \033[0m" | tee -a ssh_port.txt
        sudo sed -E -i "s/(Port|#\sPort|#Port)\s.{1,5}$/Port ${SSH_NEW_PORT}/g" /etc/ssh/sshd_config
    fi
}

# init tmux
set_tmux_plugins() {
    echo -e "[*]: Installing tmux plugins..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    tmux start-server
    tmux new-session -d
    ~/.tmux/plugins/tpm/scripts/install_plugins.sh
    tmux kill-server
}
# oh_my_zsh
install_oh_my_zsh() {
    echo -e "[*]: Installing ohmyzsh... "
    # sh -c "$(wget https://github.com/oh-my-zsh/raw/master/tools/install.sh -O-)"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    echo -e "[*]: Installing zsh plugins..."
    gh="https://github.com/"
    omz="$HOME/.oh-my-zsh/custom"
    omz_plugin="$omz/plugins/"

    git clone "$gh/romkatv/powerlevel10k" "$omz/themes/powerlevel10k"
    # echo "[*]: Changing default theme to dracula theme:"
    # git clone https://github.com/dracula/zsh.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/themes/dracula
    #  ln -s "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/themes/dracula/dracula.zsh-theme "${ZSH}"/themes/dracula.zsh-theme
    # sed -i '1,12 s/ZSH_THEME.*/ZSH_THEME=\"dracula\"/' ~/.zshrc

    git clone "$gh/zsh-users/zsh-autosuggestions" "$omz_plugin/zsh-autosuggestions"
    git clone "$gh/zsh-users/zsh-syntax-highlighting.git" "$omz_plugin/zsh-syntax-highlighting"
    # git clone "$gh/marlonrichert/zsh-autocomplete" "$omz_plugin/zsh-autocomplete"
    # git clone "$gh/clarketm/zsh-completions" "$omz_plugin/zsh-completions"
    # git clone "$gh/z-shell/F-Sy-H" "$omz_plugin/F-Sy-H"
    # git clone "$gh/djui/alias-tips" "$omz_plugin/alias-tips"
    # git clone "$gh/unixorn/git-extra-commands" "$omz_plugin/git-extra-commands"
    # git clone "$gh/Aloxaf/fzf-tab" "$omz_plugin/fzf-tab"
    # git clone "$gh/hlissner/zsh-autopair" "$omz_plugin/zsh-autopair"

    if [[ $(uname) == 'Darwin' ]]; then
        sed -i '' '1,12 s/ZSH_THEME.*/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' ~/.zshrc
        sed -i '' 's/plugins=(.*)/plugins=(zsh-syntax-highlighting zsh-autosuggestions)/g' ~/.zshrc
    fi
    if [[ $(uname) == 'Linux' ]]; then
        sed -i '1,12 s/ZSH_THEME.*/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' ~/.zshrc
        sed -i 's/plugins=(.*)/plugins=(zsh-syntax-highlighting zsh-autosuggestions)/g' ~/.zshrc
    fi
    source ~/.zshrc
    echo -e "\033[32;1m[*]: Oh-my-zsh configue success! \033[0m"
}
uninstall_oh_my_zsh() {
    rm -rf .oh-my-zsh
    rm -rf "$HOME"/.zsh*
    rm -rf "$HOME"/zsh*
}

# git
init_git() {
    if command -v git >/dev/null 2>&1; then
        echo -e "[*]: git installed, skip!"
    else
        echo -e "[*]: git installing..."
        apt install git
    fi
    git --version
    userName=$(git config user.name)
    if [ ! -n "$userName" ]; then
        read -p "Enter your git username:" userName
        git config --global user.name "$userName"
    fi
    userEmail=$(git config user.email)
    if [ ! -n "$userEmail" ]; then
        read -p "Enter your git user.email:" userEmail
        git config --global user.email "$userEmail"
    fi
    git config --list
    echo "[*]: git init completed! "

}

# vscode
install_vscode() {
    if command -v code >/dev/null 2>&1; then
        echo -e "[*]: vscode installed, skip!"
    else
        echo -e "[*]: vscode installing..."
        case $system_info in
        'mac_intel')
            brew install visual-studio-code --cask
            ;;
        'mac_arm')
            arch -arm64 brew install visual-studio-code --cask
            ;;
        *)
            sudo apt install software-properties-common apt-transport-https curl >&1
            curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - >&1
            sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" >&1
            sudo apt install code >&1
            echo -e "\033[32;1m[*]: vscode install success! \033[0m"
            ;;
        esac
    fi
}

# Nodejs
install_node() {
    if command -v nvm >/dev/null 2>&1; then
        echo -e "[*]: nvm installed, skip!"
    else
        echo -e "[*]: nvm installing..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash >&1
        source ~/.zshrc
        nvm install 16.20.0
        nvm alias default 16.20.0
        echo -e "\033[32;1m[*]: node 16.20.0 install success! \033[0m"
    fi
}
uninstall_node() {
    # 删除nvm安装目录
    rm -rf ~/.nvm

    # 删除配置文件中的nvm相关行
    sed -i '' '/nvm/d' ~/.bash_profile
    sed -i '' '/nvm/d' ~/.bashrc
    sed -i '' '/nvm/d' ~/.zshrc

    # 删除环境变量
    unset NVM_DIR

    # 重载配置文件
    source ~/.bash_profile
    source ~/.bashrc
    source ~/.zshrc

    # 删除Node.js安装目录
    sudo rm -rf /usr/local/{lib/node{,/.npm,_modules},bin,share/man}/{npm*,node*,man1/node*}

    # 删除相关环境变量
    sudo sed -i '' '/^export PATH=.*\/nodejs\/bin/d' /etc/profile
    sudo sed -i '' '/^export PATH=.*\/node\/bin/d' /etc/profile

    # 删除npm和npm缓存目录
    sudo rm -rf ~/.npm
    sudo rm -rf ~/.node-gyp

    echo -e "\033[32;1m[*]: nvm and node uninstall success! \033[0m"
}

#【Linux】conda & python3
install_python() {
    echo -e "[*]: python3-pip installing"
    sudo apt-get install -y python3-pip >/dev/null >&1

    echo -e "[*]: Anaconda3-5.2.0-Linux-x86_64.sh installing... "
    curl -O https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh | bash >&1
    echo -e "[*]: Anaconda3-5.2.0-Linux-x86_64.sh install success ! "
    echo -e "\033[32;1m[*]: Anaconda3-5.2.0-Linux-x86_64.sh install success! \033[0m"

}
# docker
install_docker() {
    if command -v docker >/dev/null 2>&1; then
        echo -e "[*]: docker installed, skip!"
        return
    fi

    echo -e "[*]: docker installing..."
    case $system_info in
    'mac_intel')
        # 加--cask 安装桌面版
        brew install docker --cask
        ;;
    'mac_arm')
        arch -arm64 brew install docker --cask
        ;;
    'ubuntu_18')
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        ;;
    *)
        sudo apt-get remove docker docker-engine docker.io containerd runc
        sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
        apt-get install ca-certificates curl gnupg lsb-release
        curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
        ;;
    esac
    echo -e "\033[32;1m[*]: docker install success! \033[0m"

}
uninstall_docker() {
    case $system_kind in
    'mac')
        rm -rf /usr/local/bin/*docker*
        rm -rf /usr/local/bin/hub-tool
        rm -rf ~/.docker
        rm -rf /var/lib/docker
        brew uninstall docker
        ;;
    'linux')
        echo -e "[*]: docker uninstalling old verison"
        sudo apt purge docker-ce docker-ce-cli containerd.io
        sudo rm -rf /var/lib/docker
        sudo groupdel docker
        echo -e "\033[32;1m[*]: docker uninstall old verison success! \033[0m"
        ;;
    *) echo "Unknown system!" && exit 1 ;;
    esac
    if command -v docker >/dev/null 2>&1; then
        echo -e "\033[32;1m[*]: docker uninstall success! \033[0m"
        return
    fi

}

# tmux
install_tmux_plugins() {
    echo -e "[*]: Installing tmux plugins... "
    # 安装Tmux插件管理器（TPM）
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    # 配置tmux的配置文件
    cat <<EOF >~/.tmux.conf
# 启用TPM插件管理器
set -g @plugin 'tmux-plugins/tpm'

# 设置插件
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-sidebar'
# 添加其他插件...

# 初始化TPM插件
run '~/.tmux/plugins/tpm/tpm'
EOF

    # 重新加载tmux配置
    tmux source-file ~/.tmux.conf
    # 安装插件
    ~/.tmux/plugins/tpm/bin/install_plugins
    echo -e "\033[32;1m[*]: Tmux plugins install success! \033[0m"
}

install_chrome() {
    echo -e "[*]: chrome installing..."
    case $system_kind in
    linux)
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo dpkg -i google-chrome-stable_current_amd64.deb
        sudo apt-get -f install
        rm google-chrome-stable_current_amd64.deb
        ;;
    mac)
        curl -O https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
        # 挂载安装包
        hdiutil attach googlechrome.dmg
        sudo cp -r "/Volumes/Google Chrome/Google Chrome.app" /Applications/
        hdiutil detach "/Volumes/Google Chrome"
        rm googlechrome.dmg
        ;;
    *) echo "Unknown system!" && exit 1 ;;
    esac
    echo -e "\033[32;1m[*]: chrome install success! \033[0m"

}

install_all() {
    echo -e "\033[37;1m install_all \033[0m"
    install_basic
    install_oh_my_zsh
    install_node
    install_python
    install_vscode
    set_ssh_port
}

#ECNUvis group proxy
scientific_surfing() {
    export http_proxy=http://172.23.148.93:7890
    export https_proxy=http://172.23.148.93:7890
    export all_proxy=socks5://172.23.148.93:7890
    echo "ECNUVis Lab Proxy Service Enabled. Traffic Usage: $_ep_ud_gb GB / $_ep_total_gb GB ($_ep_percentage%)"
    echo "Please use the proxy responsibly and do not download or stream large amounts of data."
    curl ipinfo.io
}

main() {
    if [ "$1" = "--all" ] || [ "$1" = "-a" ]; then
        install_all
        exit 0
    fi

    # Menu TUI
    echo " ===============Setting up your env=================== "
    echo " # author: heavenmei  "
    echo -e " Select an option:"
    echo -e "\033[32;1m (0) scientific_surfing \033[0m"
    echo -e "\033[32;1m (1) basic Packages \033[0m"
    echo -e "\033[32;1m (2) oh-my-zsh \033[0m"
    echo -e "\033[32;1m (3) init git \033[0m"
    echo -e "\033[32;1m (4) nvm & Nodejs \033[0m"
    echo -e "\033[32;1m (5) python & conda \033[0m"
    echo -e "\033[32;1m (6) vscode \033[0m"
    echo -e "\033[32;1m (7) docker \033[0m"
    echo -e "\033[32;1m (8) set ssh \033[0m"
    echo -e "\033[32;1m (9) tmux plugin \033[0m"
    echo -e "\033[32;1m (10) chrome \033[0m"
    echo -e "\033[31;1m (*) Anything else to exit \033[0m"
    echo -e "\033[31;1m (*) x-1 is uninstall ,eg.7-1 \033[0m"
    echo -en "\033[32;1m ==> \033[0m"

    read -r option

    case $option in
    "0") scientific_surfing ;;
    "1") install_basic ;;
    "2") install_oh_my_zsh ;;
    "3") init_git ;;
    "4") install_node ;;
    "5") install_python ;;
    "6") install_vscode ;;
    "7") install_docker ;;
    "8") set_ssh_port ;;
    "9") install_tmux_plugins ;;
    "10") install_chrome ;;
    "2-1") uninstall_oh_my_zsh ;;
    "4-1") uninstall_node ;;
    "7-1") uninstall_docker ;;
    *) echo -e "\033[31;1m Exit \033[0m" && exit 0 ;;
    esac

    exit 0
}
main "$@"
