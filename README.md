# Neovim neorg typst preview

This is a small plugin that uses regex parsing to convert Neorg-files into `.typ`
documents, which can in turn be compiled with the typst compiler.

This plugin is not fancy, it simply uses regex to parse the files. The regex is
not complete, only suitable for my needs. It is probably really slow if the
files to parse are huge. Almost real time when files are small (<200 lines).

**NOTE!** Requires python.

## Installation
With lazy:
```lua
{
    "nuhakala/nvim-typst-preview",
    config = true,
    opts = {
        -- remember to add '/' at the end of the path
        dir = "MUST BE SET"
    },
}
```
If using something else than lazy, remember to call the setup function.

## Default Config
```lua
{
    default_keymap = true,

    -- remember to add '/' at the end of the path
    dir = nil, -- directory to which write the files, it is plugin root by default
    file_name = "preview.typ", -- typst and pdf file names
    open_on_run = false, -- Open pdf with xdg-open with run command
    watch_events = { "InsertLeave", "BufEnter" }, -- Autocommand events for watching
}
```
And the default keybinds are
```lua
vim.keymap.set("n", "<leader>op", plugin.toggle, { desc = "Toggle transforming neorg file" })
```

## Features

The plugin offers following functions:
- `toggle()` Toggles between watching and not watching
- `run()` Transform neorg file and compile the typst file with `typst compile`
- `watch()` Transform neorg file when edited
- `stop_watch()` Stop watching

Transforming means converting neorg-file into typst file. Compiling means
compiling the typst file. Currently watching does not include automatic
compiling (using `typst watch`), because typst-watch command does not produce
any standard output, so figuring out when the compile process fails is
impossible (or then I do something wrong). Thus, I recommend using this plugin
to transform (using watch-command) and then run typst watch on other shell to
see the compile errors if there are some.
