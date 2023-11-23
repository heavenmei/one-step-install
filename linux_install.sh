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
    echo "[*]: apt updating "
    sudo apt upgrade -y
    echo "[*]: apt update done "
    cmdline=(lsof git curl wget unzip rename openssh-server autojump tmux)
    for prog in "${cmdline[@]}"; do
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
        echo -e "[*]: $prog install success..."
    else
        echo -e "[*]:\033[31m ${prog} install error \033[0m"
    fi
}

# zsh
install_zsh() {
    if command -v zsh >/dev/null >&1; then
        echo -e "[*]: zsh installed, skip!"
    else
        echo -e "[*]: zsh installing..."
        sudo apt install -y zsh >/dev/null >&1
        chsh -s $(which zsh)

        echo -e "[*]: ohmyzsh configuration starting... "
        echo "[!] ENTER exit manually!"
        echo "[!] 请手动 exit 才可以继续后续插件的安装（原因在于oh-my-zsh官方安装脚本会启动zsh）"
        sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O-)"

    fi
}
install_zsh_plugins() {
    echo "Installing fonts:"
    sudo apt-get install -y fonts-powerline
    echo "[*]: Changing default theme to powerlevel10k theme:"
    echo "[!]: powerlevel10k theme 会在重启终端后进行样式配置"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
    sed -i '1,12 s/ZSH_THEME.*/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/' ~/.zshrc

    # echo "[*]: Changing default theme to dracula theme:"
    # git clone https://github.com/dracula/zsh.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/themes/dracula
    #  ln -s "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/themes/dracula/dracula.zsh-theme "${ZSH}"/themes/dracula.zsh-theme
    # sed -i '1,12 s/ZSH_THEME.*/ZSH_THEME=\"dracula\"/' ~/.zshrc

    echo "[*]: Installing text highlighting plugin:"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
    echo "[*]: Installing autosuggestion plugin:"
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
    sed -i 's/plugins=(.*)/plugins=(zsh-syntax-highlighting zsh-autosuggestions)/g' ~/.zshrc
    source ~/.zshrc
    echo "[*]: Installation complete!"

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
    # git config --list
    echo "[*]: git init completed! "

}

# vscode
install_vscode() {
    if command -v code >/dev/null 2>&1; then
        echo -e "[*]: vscode installed, skip!"
    else
        echo -e "[*]: vscode installing..."
        sudo apt install software-properties-common apt-transport-https curl >&1
        curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - >&1
        sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" >&1
        sudo apt install code >&1
        echo -e "[*]: vscode install success.."
    fi
}

# Nodejs
install_node() {
    if command -v nvm >/dev/null 2>&1; then
        echo -e "[*]: nvm installed, skip!"
    else
        echo -e "[*]: nvm installing..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash >&1
        {
            echo 'export NVM_DIR="$HOME/.nvm"'
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm'
            echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion'
        } >>~/.zshrc
        source ~/.zshrc

        if command -v nvm >/dev/null 2>&1; then
            echo -e "[*]:\033[31m nvm install error \033[0m"
        else
            nvm --version
            npm -v
            nvm install 16.20.0
            nvm alias default 16.20.0
            echo -e "[*]: node 16.20.0 install success!"
        fi

        # curl -fsSL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
        # apt install -y nodejs >/dev/null 2>&1
    fi
}

# conda & python3
install_python() {
    echo -e "[*]: python3-pip installing"
    sudo apt-get install -y python3-pip >/dev/null >&1

    echo -e "[*]: Anaconda3-5.2.0-Linux-x86_64.sh installing... "
    curl -O https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh | bash >&1
    echo -e "[*]: Anaconda3-5.2.0-Linux-x86_64.sh install sucess ! "
}
# docker
install_docker() {
    if command -v docker >/dev/null 2>&1; then
        echo -e "[*]: docker installed, skip!"
    else
        echo -e "[*]: docker installing..."
        curl -fsSL https://get.docker.com -o get-docker.sh
    fi
}

menu_options() {
    echo ""
    echo " ==============Additional Configuration Options================== "
    echo -e "1. nvm & Nodejs "
    echo -e "2. pythonthon & conda"
    echo -e "3. docker"
    echo -e "0. Exit \n"
    echo -en "Enter an option: "
}

extraMenu() {
    while [ 1 ]; do
        menu_options
        read -n option
        case $option in
        0)
            break
            ;;
        1)
            echo ""
            install_node
            ;;
        2)
            echo ""
            install_python
            ;;
        *)
            clear
            echo "Sorry, wrong selection"
            ;;
        esac
        echo -e "\n[!]: Hit any key to continue"
        read -n 1 line
    done
    clear
}

system_config
init_git
install_zsh
install_zsh_plugins
install_vscode
extraMenu
