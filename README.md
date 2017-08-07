# vimrc
这里是我的 vim 配置文件

## 安装

```console
git clone https://github.com/qhwa/vimrc.git vimrc
cd vimrc
cp -a .vim_runtime ~/
[ -f "$HOME/.vimrc" ] && cp ~/.vimrc ~/.vimrc.bak
cp -a .vimrc ~/.vimrc
```

### 安装字体

字体文件在 `fonts` 内

### 安装插件

在 vim 命令模式中执行 `BundleInstall`

### Markdown 实时预览

```console
# 如果已经安装了 Node.js
npm -g install instant-markdown-d
```

参考 [instant-markdown](https://github.com/suan/vim-instant-markdown#installation)

## 截图
