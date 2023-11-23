#!/usr/bin/env bash

uninstall_zsh() {
    sh -c "uninstall_zsh"
    rm -rf "$HOME"/.zsh*
    rm -rf "$HOME"/zsh*
    rm -rf .oh-my-zsh
}
declare -a common_packages=(
    curl wget git zsh tmux bat unzip
    silversearcher-ag fonts-powerline
)

get_system_info() {
    if [[ $(uname) == 'Darwin' ]]; then
        echo "mac"
        return $?
    fi

    if [[ $(uname) == 'Linux' ]]; then
        echo "Linux"
        return $?
    fi
}
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
    system_kind=$(get_system_info)
    echo -e "[*]: Installing packages for $system_kind..."
    case $system_kind in
    ubuntu) install_linux ;;
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
    sed -i '' '1,12 s/ZSH_THEME.*/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' ~/.zshrc
    # sed -i '1,12 s/ZSH_THEME.*/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' ~/.zshrc

    # echo "[*]: Changing default theme to dracula theme:"
    # git clone https://github.com/dracula/zsh.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/themes/dracula
    #  ln -s "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/themes/dracula/dracula.zsh-theme "${ZSH}"/themes/dracula.zsh-theme
    # sed -i '1,12 s/ZSH_THEME.*/ZSH_THEME=\"dracula\"/' ~/.zshrc

    # https://github.com/zsh-users/zsh-autosuggestions
    git clone "$gh/zsh-users/zsh-autosuggestions" "$omz_plugin/zsh-autosuggestions"
    git clone "$gh/zsh-users/zsh-syntax-highlighting.git" "$omz_plugin/zsh-syntax-highlighting"
    # git clone "$gh/marlonrichert/zsh-autocomplete" "$omz_plugin/zsh-autocomplete"
    # git clone "$gh/clarketm/zsh-completions" "$omz_plugin/zsh-completions"
    # git clone "$gh/z-shell/F-Sy-H" "$omz_plugin/F-Sy-H"
    # git clone "$gh/djui/alias-tips" "$omz_plugin/alias-tips"
    # git clone "$gh/unixorn/git-extra-commands" "$omz_plugin/git-extra-commands"
    # git clone "$gh/Aloxaf/fzf-tab" "$omz_plugin/fzf-tab"
    # git clone "$gh/hlissner/zsh-autopair" "$omz_plugin/zsh-autopair"

    # sed -i 's/plugins=(.*)/plugins=(zsh-syntax-highlighting zsh-autosuggestions)/g' ~/.zshrc
    sed -i '' 's/plugins=(.*)/plugins=(zsh-syntax-highlighting zsh-autosuggestions)/g' ~/.zshrc
    source ~/.zshrc
    echo -e "\033[32;1m[*]: Oh-my-zsh configue success! \033[0m"
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

#【Linux】 vscode
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
        source ~/.zshrc
        nvm install 16.20.0
        nvm alias default 16.20.0
        echo -e "[*]: node 16.20.0 install success!"
    fi
}

#【Linux】conda & python3
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

install_all() {
    echo -e "\033[37;1m install_all \033[0m"
    # install_basic
    # init_git
    # extraMenu
}

scientific_surfing() {
    source <(curl -s 172.23.148.93/s/ecnuproxy.sh)
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
    echo -e "\033[31;1m (*) Anything else to exit \033[0m"
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
    *) echo -e "\033[31;1m Exit \033[0m" && exit 0 ;;
    esac

    exit 0
}
main "$@"
