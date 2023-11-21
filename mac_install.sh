#!/bin/bash
# 默认安装Homebrew、git、

PS3='Please enter your choice: '
options=("vscode" "node" "python" "Quit")



select opt in "${options[@]}"; do
    case $opt in
    "Option 1")
        echo "you chose choice 1"
        ;;
    "Option 2")
        echo "you chose choice 2"
        ;;
    "Option 3")
        echo "you chose choice 3"
        ;;
    "Quit")
        break
        ;;
    *) echo invalid option ;;
    esac
done
