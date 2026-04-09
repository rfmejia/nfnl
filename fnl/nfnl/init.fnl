(local {: define : autoload} (require :nfnl.module))
(local notify (autoload :nfnl.notify))
(local vim _G.vim)

(local M (define :nfnl))

(when vim
  (notify.warn "require(\"nfnl\") is deprecated. nfnl now activates via ftplugin. You can remove require(\"nfnl\") from your config."))

(fn M.setup [opts]
  "Deprecated. Set vim.g variables directly instead."
  (notify.warn "nfnl.setup() is deprecated. Set vim.g.nfnl#compile_on_write directly instead.")
  (when opts
    (set vim.g.nfnl#compile_on_write opts.compile_on_write)))

M
