-- [nfnl] ftplugin/fennel.fnl
local _local_1_ = require("nfnl.module")
local autoload = _local_1_.autoload
local callback = autoload("nfnl.callback")
local vim = _G.vim
local minimum_neovim_version = "0.9.0"
if (0 == vim.fn.has(("nvim-" .. minimum_neovim_version))) then
  error(("nfnl requires Neovim > v" .. minimum_neovim_version))
else
end
return callback["setup-buffer"]({file = vim.fn.expand("%"), buf = vim.api.nvim_get_current_buf()})
