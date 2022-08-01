Pre down my vim config and incrementally migrate that to lua, in prep for doing fun tree-sitter/lsp thingies.

# Links

https://neovim.io/doc/user/lua.html

vim.opt vs vim.o ? I think it's that vim.opt is more powerful and more verbose https://github.com/nanotee/nvim-lua-guide#using-meta-accessors

keyboard remaps, commands

https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/

https://github.com/nanotee/nvim-lua-guide#debugging-lua-mappingscommandsautocommands

https://github.com/nanotee/nvim-lua-guide#testing-lua-code:q

Try stuff in https://toroid.org/modern-neovim

Debug with:

```lua
:lua =vim.loop
```

# Adding Packer

It looks like I need to modify the packpath when I download packer:


See it with `:set packpath?' or:

```
:lua =vim.opt.packpath:get()
```

```
{ 
"/Users/bbkane/.config/nvim",
"/Users/bbkane/.config/nvim/after" 
"/Users/bbkane/.local/share/nvim/site",
"/Users/bbkane/.local/share/nvim/site/after",
"/etc/xdg/nvim",
"/etc/xdg/nvim/after",
"/usr/local/Cellar/neovim/0.7.2_1/lib/nvim",
"/usr/local/Cellar/neovim/0.7.2_1/share/nvim/runtime",
"/usr/local/share/nvim/site",
"/usr/local/share/nvim/site/after",
"/usr/share/nvim/site",
"/usr/share/nvim/site/after",
}
```

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

using material.nvim - the code block text isn't highlighting code differently than block text..

Requires a C compiler - Zig with scoop on Windows?

```
TSInstall markdown markdown_inline python bash
```

# Mason + Go support

Ok, I think I might need to combine this with a completion plugin, like nvim-cmp, but let's install mason first...

https://github.com/williamboman/nvim-config/blob/116650568adc856d8a556a54029d67e31424aed8/lua/wb/plugins.lua#L105

I use C-x,C-o to trigger autocomplete

Let's save this, then make a new experiment that sets envvars to change stdpath (stdpath looks like it reads envvars each time). Then I can use stuff more directly (because things are still getting in my ~/.local/share/nvim directory

# nvim3-stdpath

Ok. At the top of this init.lua, let's change the envvars that stdpath reads from, then checkout the runtime path and see what happens

Packer log at:

 ~/.cache/nvim/packer.nvim.log
