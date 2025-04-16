local plugin = {}
local H = require("neorg-typst-preview.utils")
local tr = require("neorg-typst-preview.transform")
local st = require("neorg-typst-preview.string-utils")

-- Default config
plugin.config = {
	default_keymap = true,
	dir = nil, -- remember to add '/' at the end of the path
	file_name = "preview.typ",
	open_on_run = false,
	watch_events = { "InsertLeave", "BufEnter" },
}
H.set_default_config(plugin.config)

-- local Job = require("plenary.job")
local python_dir = nil
local python_script = "neorg.py"
local debounce = true
local toggle = true
local typstwatch_augroup = vim.api.nvim_create_augroup("typstwatch", { clear = true })
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
	vim.api.nvim_create_autocmd(plugin.config.watch_events, {
		group = typstwatch,
		pattern = "*.norg",
		callback = function()
			H.transform(plugin.config, python_script, python_dir)
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

	toggle = false
end

plugin.stop_watch = function()
	vim.api.nvim_clear_autocmds({ group = "typstwatch" })
	vim.notify("Stopped watching open buffer", "info", { title = "Typst preview" })
	toggle = true
end

plugin.run = function()
	H.transform(plugin.config, python_script, python_dir)
	H.compile(plugin.config)
end

plugin.toggle = function()
	if toggle then
		plugin.watch()
	else
		plugin.stop_watch()
	end
end

-- TODO: linkkien korjaus, ota huomioon myös linkit mitkä
-- viittaa headeriin tai internettiin
plugin.testi = function()
	local prev = plugin.config.dir .. plugin.config.file_name
	local file = io.open(prev, "w")
	if file == nil then
		vim.notify("Could not open preview file")
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local cases = tr.get_cases()

	local index = 1
	while index < #lines do
		-- local line = st.trim_string(lines[index])
		local line = lines[index]
		if st.startswith(line, "-") then
			line = tr.list(line)
		end
		if st.startswith(line, "* ") or st.startswith(line, "**") then
			line = tr.header(line)
		end
		for pattern, func in pairs(cases) do
			if st.startswith(line, pattern) then
				index = func(index, lines, file, #lines)
				goto continue
			end
		end
		if string.find(line, "{:(.*):(.*)}") then
			index = tr.parse_link(index, lines, file)
		else
			file:write(line .. "\n")
		end

		::continue::
		index = index + 1
	end

	file:close()
end

return plugin
