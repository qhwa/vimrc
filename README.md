# vimrc
这里是我的 vim 配置文件, 已经内置了:

- [NERD_tree 插件](https://github.com/scrooloose/nerdtree)
- [Powerline 插件](https://github.com/godlygeek/tabular)
- [Tabularize 对齐](https://github.com/godlygeek/tabular)
- Elixir/jade/less/sass/mxml/coffeeScript/nginx/... 等 web 开发相关的语法支持
- [Gundo 插件](https://github.com/sjl/gundo.vim) 历史版本可视化
- 无限历史记录，即使文件被关闭
- [SnipMate](https://github.com/garbas/vim-snipmate)
- zen coding
- [MRU](https://github.com/vim-scripts/mru.vim) (most recently used)
- [comments.vim](http://www.vim.org/scripts/script.php?script_id=1528) 快速注释、取消注释代码

## 安装

```console
git clone https://github.com/qhwa/vimrc.git vimrc
cd vimrc
cp -a .vim_runtime ~/
[ -f "$HOME/.vimrc" ] && cp ~/.vimrc ~/.vimrc.bak
cp -a .vimrc ~/.vimrc
```

### 安装字体

使用 `Lucida Typewriter` 字体, 文件在 `fonts` 内

### 安装插件

在 vim 命令模式中执行 `BundleInstall`

### Markdown 实时预览

```console
# 如果已经安装了 Node.js
npm -g install instant-markdown-d
```

参考 [instant-markdown](https://github.com/suan/vim-instant-markdown#installation)

## 截图
![image](https://user-images.githubusercontent.com/43009/29046407-f907b4aa-7bf9-11e7-9643-b11e5fdec2d7.png)
