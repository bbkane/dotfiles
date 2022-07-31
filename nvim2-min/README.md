Pre down my vim config and incrementally migrate that to lua, in prep for doing fun tree-sitter/lsp thingies.

# Links

https://neovim.io/doc/user/lua.html

vim.opt vs vim.o ? I think it's that vim.opt is more powerful and more verbose https://github.com/nanotee/nvim-lua-guide#using-meta-accessors

keyboard remaps, commands

https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/

https://github.com/nanotee/nvim-lua-guide#debugging-lua-mappingscommandsautocommands

https://github.com/nanotee/nvim-lua-guide#testing-lua-code:q

Try stuff in https://toroid.org/modern-neovim


# Adding Packer

It looks like I need to modify the packpath when I download packer:


See it with `:set packpath?'

```
packpath=
/etc/xdg/nvim
/etc/xdg/nvim/after
/usr/local/Cellar/neovim/0.7.2_1/share/nvim/runtime
/usr/local/Cellar/neovim/0.7.2_1/lib/nvim
/usr/local/share/nvim/site/after
/usr/local/share/nvim/site
/usr/share/nvim/site
/usr/share/nvim/site/after
~/.config/nvim
~/.config/nvim/after
~/.local/share/nvim/site
~/.local/share/nvim/site/after
```

I can set it with https://superuser.com/a/1466466/643441

I don't think I need to set it as long as 


https://neovim.io/doc/user/starting.html - "Standard Paths"

I can modify the path with: https://www.reddit.com/r/neovim/comments/wacwhy/comment/ii0adg9/?utm_source=share&utm_medium=web2x&context=3

Note that vim.fn.stdpath('config') = "/Users/bbkane/.local/share/nvim" , which is in the packpath by default. So my packer install path is going to be that + 

# Adding Tree-sitter + Markdown

Painless so far... TODO: get a colorscheme that hightlights the text in code blocks and check long files

using material.nvim - the code block text isn't highlighting code differently than block text..

# TODO

- Install packer.nvim and use it to install a commenting plugin - make sure packer puts stuff into ~/.config/nvim
- Install markdown plugins (tree-sitter)

