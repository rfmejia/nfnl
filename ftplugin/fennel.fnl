(local {: autoload} (require :nfnl.module))
(local callback (autoload :nfnl.callback))
(local vim _G.vim)

(local minimum-neovim-version "0.9.0")

(when (= 0 (vim.fn.has (.. "nvim-" minimum-neovim-version)))
  (error (.. "nfnl requires Neovim > v" minimum-neovim-version)))

(callback.setup-buffer
  {:file (vim.fn.expand "%")
   :buf (vim.api.nvim_get_current_buf)})
