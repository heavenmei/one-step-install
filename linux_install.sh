#!/usr/bin/env bash

echo ""
echo " ========================================================= "
echo " \\            ubuntu 环境部署脚本           / "
echo " \\            默认安装git、zsh、ssh、vscode           / "
echo " ========================================================= "
echo " # author: heavenmei                  "
echo -e "\\n"

chmod -R 777 ./
#科学上网
sh -c "$(source <(curl -s 172.23.148.93/s/ecnuproxy.sh))"

# basic tools
system_config() {
    echo "[Tips]: apt updating "
    apt update && sudo apt upgrade -y
    # 常用软件安装
    cmdline=(
        "which lsof"
        "which man"
        "which tmux"
        "which htop"
        "which autojump"
        "which iotop"
        "which ncdu"
        "which jq"
        "which telnet"
        "which p7zip"
        "which axel"
        "which rename"
        "which vim"
        "which sqlite3"
        "which lrzsz"
        "which unzip"
        "which git"
        "which curl"
        "which wget"
    )
    for prog in "${cmdline[@]}"; do
        soft=$($prog)
        if [ "$soft" ] >/dev/null 2>&1; then
            echo -e "[Tips]: $soft installed, skip!"
        else
            name=$(echo -e "$prog" | ag -o '[\w-]+$')
            apt install -y "${name}" >/dev/null 2>&1
            echo -e "[Tips]: ${name} installing..."
        fi
    done
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
    if command -v giy >/dev/null 2>&1; then
        echo -e "[Tips]: git installed, skip!"
    else
        echo -e "[Tips]: git installing..."
        apt install git
        git --version
        read -p "Enter your git username:" username
        git config --global username "$username"
        read -p "Enter your git user.email:" userEmail
        git config --global user.email "$userEmail"
        git config --list
        echo "[Tips]: git init completed! "
    fi
}

system_config
init_git

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
