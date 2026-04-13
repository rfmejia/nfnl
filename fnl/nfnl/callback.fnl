(local {: autoload : define} (require :nfnl.module))
(local core (autoload :nfnl.core))
(local str (autoload :nfnl.string))
(local fs (autoload :nfnl.fs))
(local nvim (autoload :nfnl.nvim))
(local compile (autoload :nfnl.compile))
(local config (autoload :nfnl.config))
(local api (autoload :nfnl.api))
(local notify (autoload :nfnl.notify))
(local vim _G.vim)

(local M (define :nfnl.callback))

(fn M.supported-path? [file-path]
  "Returns true if we can work with the given path. Right now we support a path if it's a string and it doesn't start with a protocol segment like fugitive://..."
  (or
    (when (core.string? file-path)
      (not (file-path:find "^[%w-]+:/")))
    false))

(fn buf-write-callback [ev]
  "Called on BufWritePost. Finds the .nfnl.fnl config and compiles the file
  if trusted."
  (let [path (fs.full-path (. ev :file))]
    (when (M.supported-path? path)
      (let [{: config : root-dir : cfg} (config.find-and-load (fs.basename path))]
        (when config
          (compile.into-file
            {: root-dir
             : cfg
             : path
             :source (nvim.get-buf-content-as-string (. ev :buf))})

          (when (cfg [:orphan-detection :auto?])
            (api.find-orphans
              {:dir root-dir
               :passive? true
               : config : root-dir : cfg}))))))
  nil)

(fn M.setup-buffer [ev]
  "Called by ftplugin/fennel.fnl for every fennel buffer. Registers the
  BufWritePost autocmd and all :Nfnl* buffer-local commands. Trust is checked
  at write time, not here."

  (when (not= false vim.g.nfnl#compile_on_write)
    (vim.api.nvim_create_autocmd
      ["BufWritePost"]
      {:group (vim.api.nvim_create_augroup (str.join ["nfnl-on-write" ev.buf]) {})
       :buffer ev.buf
       :callback buf-write-callback}))

  (vim.api.nvim_buf_create_user_command
    ev.buf :NfnlFile
    #(api.dofile (core.first (core.get $ :fargs)))
    {:desc "Run the matching Lua file for this Fennel file from disk. Does not recompile the Lua, you must use nfnl to compile your Fennel to Lua first. Calls nfnl.api/dofile under the hood."
     :force true
     :complete "file"
     :nargs "?"})

  (vim.api.nvim_buf_create_user_command
    ev.buf :NfnlCompileFile
    #(api.compile-file {:path (core.first (core.get $ :fargs))})
    {:desc "Executes (nfnl.api/compile-file) which compiles the current file or the one provided as an argumet. The output is written to the appropriate Lua file."
     :force true
     :complete "file"
     :nargs "?"})

  (vim.api.nvim_buf_create_user_command
    ev.buf :NfnlCompileAllFiles
    #(api.compile-all-files (core.first (core.get $ :fargs)))
    {:desc "Executes (nfnl.api/compile-all-files) which will, you guessed it, compile all of your files."
     :force true
     :complete "file"
     :nargs "?"})

  (vim.api.nvim_buf_create_user_command
    ev.buf :NfnlFindOrphans
    #(api.find-orphans {:dir (core.first (core.get $ :fargs))})
    {:desc "Executes (nfnl.api/find-orphans) which will find and display all Lua files that no longer have a matching Fennel file."
     :force true
     :complete "file"
     :nargs "?"})

  (vim.api.nvim_buf_create_user_command
    ev.buf :NfnlDeleteOrphans
    #(api.delete-orphans {:dir (core.first (core.get $ :fargs))})
    {:desc "Executes (nfnl.api/delete-orphans) deletes any orphan Lua files that no longer have their original Fennel file they were compiled from."
     :force true
     :complete "file"
     :nargs "?"}))

M
