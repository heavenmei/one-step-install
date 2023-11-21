#!/usr/bin/env bash

echo ""
echo " ========================================================= "
echo "            ubuntu 环境部署脚本            "
echo "             默认安装git、zsh、ssh、vscode            "
echo " ========================================================= "
echo " # author: heavenmei                  "
echo -e "\n"

sudo chmod -R 777 ./
# source <(curl -s 172.23.148.93/s/ecnuproxy.sh)

# basic tools
system_config() {
    echo "[Tips]: apt updating "
    sudo apt upgrade -y
    echo "[Tips]: apt update done "
    cmdline=(lsof git curl wget unzip rename)
    for prog in "${cmdline[@]}"; do
        if command -v "$prog" >/dev/null 2>&1; then
            echo -e "[Tips]: $prog installed, skip!"
        else
            sudo apt install -y "$prog" >/dev/null
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
    if command -v zsh >/dev/null 2>&1; then
        echo -e "[Tips]: zsh installed, skip!"
    else
        echo -e "[Tips]: zsh installing..."
        apt install -y zsh >/dev/null 2>&1
        echo -e "[Tips]: ohmyzsh configuration starting... "
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        chsh -s /bin/zsh
        echo -e "[Tips]: dracula theme configuring... "
        git clone git://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM"/themes >/dev/null 2>&1
        sed -i 's@ZSH_THEME="dracula"@ZSH_THEME="xiong-chiamiov-plus"@g' ~/.zshrc
        sed -i 's@plugins=(.*)@plugins=(git extract zsh-syntax-highlighting autojump zsh-autosuggestions)@g' ~/.zshrc
        {
            echo 'alias cat="/usr/bin/bat"'
            echo 'alias myip="curl ifconfig.io/ip"'
            echo 'alias c=clear'
        } >>~/.zshrc
        echo -e "[Tips]: zsh-syntax-highlighting plugin downloading... "
        git clone git://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM"/plugins/zsh-syntax-highlighting >/dev/null 2>&1
        echo -e "[Tips]: zsh-autosuggestions plugin  downloading... "
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM"/plugins/zsh-autosuggestions >/dev/null 2>&1
        source ~/.zshrc
    fi
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
    git config --list
    echo "[Tips]: git init completed! "

}

system_config
init_git
install_zsh

# PS3='Please enter your choice: '
# options=("vscode" "node" "python" "Quit")
# select opt in "${options[@]}"; do
#     case $opt in
#     "Option 1")
#         echo "you chose choice 1"
#         ;;
#     "Option 2")
#         echo "you chose choice 2"
#         ;;
#     "Option 3")
#         echo "you chose choice 3"
#         ;;
#     "Quit")
#         break
#         ;;
#     *) echo invalid option ;;
#     esac
# done
