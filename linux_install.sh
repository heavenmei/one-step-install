#!/usr/bin/env bash

echo ""
echo " ========================================================= "
echo "            ubuntu 环境部署脚本            "
echo "            默认安装git、zsh、ssh、vscode、node、python            "
echo " ========================================================= "
echo " # author: heavenmei                  "
echo -e "\n"

sudo chmod -R 777 ./
curl -s 172.23.148.93/s/ecnuproxy.sh | bash

uninstall() {
    rm -rf "$HOME"/.zsh*
    rm -rf "$HOME"/zsh*
    rm -rf .oh-my-zsh
}

# basic tools
system_config() {
    echo "[Tips]: apt updating "
    sudo apt upgrade -y
    echo "[Tips]: apt update done "
    cmdline=(lsof git curl wget unzip rename openssh-server autojump tmux)
    for prog in "${cmdline[@]}"; do
        if command -v "$prog" >/dev/null >&1; then
            echo -e "[Tips]: $prog installed, skip!"
        else
            sudo apt install -y "$prog" >/dev/null >&1
            if [ $? -eq 0 ]; then
                echo -e "[Tips]: $prog install success..."
            else
                echo -e "[Tips]:\033[31m ${prog} install error \033[0m"
            fi
        fi
    done
    # vim 单独安装
    sudo apt install -y vim >/dev/null
    if [ $? -eq 0 ]; then
        echo -e "[Tips]: $prog install success..."
    else
        echo -e "[Tips]:\033[31m ${prog} install error \033[0m"
    fi
}

# zsh
install_zsh() {
    if command -v zsh >/dev/null >&1; then
        echo -e "[Tips]: zsh installed, skip!"
    else
        echo -e "[Tips]: zsh installing..."
        sudo apt install -y zsh >/dev/null >&1
        chsh -s $(which zsh)

        echo -e "[Tips]: ohmyzsh configuration starting... "
        echo "[!] ENTER exit manually!"
        echo "[!] 请手动 exit 才可以继续后续插件的安装（原因在于oh-my-zsh官方安装脚本会启动zsh）"
        sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O-)"

    fi
}

install_zsh_plugins() {
    # install dracula

    # install zsh-autosuggestions
    echo "[*]: Installing autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions

    # install zsh-syntax-highlighting

    echo "[*]: Installing text highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting

}

# git
init_git() {
    if command -v git >/dev/null 2>&1; then
        echo -e "[Tips]: git installed, skip!"
    else
        echo -e "[Tips]: git installing..."
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
    # git config --list
    echo "[Tips]: git init completed! "

}

# vscode
install_vscode() {
    if command -v vscode >/dev/null 2>&1; then
        echo -e "[Tips]: vscode installed, skip!"
    else
        echo -e "[Tips]: vscode installing..."
        sudo apt install software-properties-common apt-transport-https curl >&1
        curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - >&1
        sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" >&1
        sudo apt install code >&1
        echo -e "[Tips]: vscode install success.."
    fi
}

# conda & python3
install_python() {
    echo -e "apt-get install -y python3-pip"
    apt-get install -y python3-pip >/dev/null >&1

    echo -e "[Tips]: Anaconda3-5.2.0-Linux-x86_64.sh installing... "
    curl -O https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh | bash >&1
    echo -e "[Tips]: Anaconda3-5.2.0-Linux-x86_64.sh install sucess ! "
}
# docker
install_docker() {
    if command -v docker >/dev/null 2>&1; then
        echo -e "[Tips]: docker installed, skip!"
    else
        echo -e "[Tips]: docker installing..."
        curl -fsSL https://get.docker.com -o get-docker.sh
    fi
}
# Nodejs
install_node() {
    if command -v nvm >/dev/null 2>&1; then
        echo -e "[Tips]: nvm installed, skip!"
    else
        echo -e "[Tips]: nvm installing..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash >&1
        {
            echo 'export NVM_DIR="$HOME/.nvm"'
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm'
            echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion'
        } >>~/.zshrc

        if command -v nvm >/dev/null 2>&1; then
            echo -e "[Tips]:\033[31m nvm install error \033[0m"
        else
            nvm --version
            npm -v
            nvm install 16.20.0
            nvm alias default 16.20.0
            echo -e "[Tips]: node 16.20.0 install success!"
        fi

        # curl -fsSL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
        # apt install -y nodejs >/dev/null 2>&1
    fi
}

system_config
init_git
install_zsh
install_zsh_plugins
# install_vscode
