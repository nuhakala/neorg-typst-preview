local plugin = {}
local H = require("nvim-typst-preview.utils")

-- Default config
plugin.config = {
	default_keymap = true,
    dir = nil, -- remember to add '/' at the end of the path
    file_name = "preview.typ",
}
H.set_default_config(plugin.config)

-- local Job = require("plenary.job")
local python_dir = nil
local python_script = "neorg.py"
local debounce = true
local toggle = true
-- local watchjob = nil

plugin.setup = function(cfg)
	local config = H.setup_config(cfg)
	plugin.config = config

    python_dir = H.get_plugin_root() .. "python/"

    if plugin.config.dir == nil then
        plugin.config.dir = H.get_plugin_root()
    else
        local path = require("plenary.path").new(plugin.config.dir)
        plugin.config.dir = path:expand()
    end

	-- Do some initial stuff
	if config.default_keymap then
        -- Automatically compile file into typst file
        vim.keymap.set("n", "<leader>op", plugin.toggle, { desc = "Start generating typst file" })
	end
end

plugin.watch = function()
    vim.api.nvim_create_autocmd({"BufModifiedSet", "BufReadPost"}, {
        group = typstwatch,
        pattern = '*.norg',
        callback = function() 
            if debounce then
                debounce = false
                vim.defer_fn(function ()
                    H.transform(plugin.config, python_script, python_dir)
                    debounce = true
                end, 200)
            end
        end,
    })
    vim.notify("Watching open buffer", "info", { title = "Typst preview" })

    -- Compiling is not so nice, because typst compiler does no print anything
    -- to stdout or stderror, so catching compiler errors is impossible. It is
    -- nicer to work on file when I see the compiler results and know what is wrong.

	-- watchjob = Job:new({
	-- 	command = "typst",
	-- 	args = { "watch", "--open=xdg-open", target_name },
	-- 	detached = true,
	-- 	cwd = "/home/jaba/OmatProjektit/nvim-typst-preview/python/",
	-- }):start()
end

plugin.stop_watch = function()
    vim.api.nvim_clear_autocmds({group = "typstwatch"})
    vim.notify("Stopped watching open buffer", "info", { title = "Typst preview" })
    -- if watchjob ~= nil then
    --     watchjob.shutdown()
    -- end
end

plugin.run = function()
    H.transform(plugin.config, python_script, source_file)
	H.compile(plugin.config)
end

plugin.toggle = function()
    if toggle then
        plugin.watch()
    else
        plugin.stop_watch()
    end
end


return plugin
