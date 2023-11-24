# 一键安装环境
方便自己配置环境， Both for Mac OS and Ubuntu
## 1、系统安装

ubuntu分配桌面版和服务器版，在主机上安装桌面版

1. 下载镜像链接https://releases.ubuntu.com/
2. mac使用etcher烧录到U盘：[https://etcher.balena.io/](https://etcher.balena.io/)
3. f2 进入bios界面，设置u盘启动
4. 按照界面提示安装ubuntu
## 2、显卡驱动

下载显卡驱动：https://www.nvidia.com/Download/index.aspx?lang=en-us

## 3、一键配置脚本

https://github.com/Heaven117/one-step-install

下载一键安装脚本，`bash one_step_install.sh`

### oh-my-zsh

1. `zsh one_step_install.sh`, 选择ohmyzsh
    
2. 重启终端，配置主题

如果安装卡住，可能是网络不好
解决1、`zsh one_step_install.sh`, 选择oscientific_surfing，再次安装
解决2、直接 `zsh install_ohmyzsh.sh`, 

### nvm & node

默认安装nvm，及node 16.20.0

