local H = {}
local Job = require("plenary.job")

H.get_plugin_root = function()
	local this_path = debug.getinfo(2, "S").source:sub(2)
	local path = require("plenary.path").new(this_path)
	local parents = path:parents()
	return parents[3] .. "/"
end

H.transform = function(cfg, python_script, python_dir)
	local source_file = vim.fn.expand("%:p")
	Job:new({
		command = "python3",
		args = { python_script, source_file, cfg.dir .. cfg.file_name },
		cwd = python_dir,
		enable_recording = true,
	}):start()
end

H.compile = function(cfg)
	Job:new({
		command = "typst",
		args = { "compile", "--open=xdg-open", cfg.file_name },
		cwd = H.get_plugin_root(),
		enable_recording = true,
		enable_handlers = true,
		on_stdout = function(error, data)
			vim.print(data)
		end,
	}):start()
end

H.set_default_config = function(cfg)
	H.default_config = vim.deepcopy(cfg)
end

---Combine default and user-provided configs
---@param config table user-provided config
---@return table # Combined config
H.setup_config = function(config)
	vim.validate({ config = { config, "table", true } })
	config = vim.tbl_deep_extend("force", vim.deepcopy(H.default_config), config or {})

	vim.validate({
		-- examples
		default_keymap = { config.default_keymap, "boolean" },
		dir = { config.dir, "string" },
		file_name = { config.file_name, "string" },
		-- mode_events = { config.mode_events, "table" },
	})

	return config
end

return H
