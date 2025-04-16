local H = {}
local SH = require("neorg-typst-preview.string-utils")

---@param start_line integer line number
---@param lines table containing lines
---@param file file* to write
---@return integer
H.meta_data = function(start_line, lines, file, max_lines)
	local index = start_line + 1
	local line = lines[index]
	local meta = {
		title = { pat = "title:", value = {} },
		desc = { pat = "description:", value = {} },
		auth = { pat = "authors:", value = {} },
		cat = { pat = "categories:", value = {} },
		created = { pat = "created:", value = {} },
		updated = { pat = "updated:", value = {} },
		version = { pat = "version:", value = {} },
	}

	-- iterate over meta
	while not string.find(line, "@end") and index < max_lines do
		-- match each key-value pair
		for _, v in pairs(meta) do
			if string.find(line, v.pat) then
				local value = SH.trim_string(SH.split_string(line, ":")[2])

				-- Check if the value is table
				if value == "[" then
					index = index + 1
					line = SH.trim_string(lines[index])
					while not string.find(line, "%]") and index < max_lines do
						table.insert(v.value, line)
						index = index + 1
						line = SH.trim_string(lines[index])
					end
				else
					table.insert(v.value, value)
				end
			end
		end

		index = index + 1
		line = lines[index]
	end

	for k, v in pairs(meta) do
		file:write("#let " .. k .. ' = "' .. table.concat(v.value, ", ") .. '"\n')
	end

	file:write([[
#import "./preview_template.typ": *
#show: preview.with(
	title, desc, auth, updated, created, version, cat
)
]])

	return index
end

---@param start_line integer line number
---@param lines table containing lines
---@param file file* to write
---@param max_lines integer max amount of lines
---@return integer
H.definition = function(start_line, lines, file, _)
	local line = SH.trim_string(lines[start_line])
	if string.len(line) == 2 then
		file:write("]\n")
	else
		local title = SH.get_after(line, "$$ ")
		file:write('#definition("' .. title .. '")[\n')
	end
	return start_line
end

---@param start_line integer line number
---@param lines table containing lines
---@param file file* to write
---@param max_lines integer max amount of lines
---@return integer
H.code_block = function(start_line, lines, file, max_lines)
	file:write("```\n")
	local index = start_line + 1
	local line = lines[index]
	while not string.find(line, "@end") and index < max_lines do
		file:write(line .. "\n")
		index = index + 1
		line = lines[index]
	end
	file:write("```\n")
	return index
end

---@param start_line integer line number
---@param lines table containing lines
---@param file file* to write
---@param max_lines integer max amount of lines
---@return integer
H.math_block = function(start_line, lines, file, max_lines)
	local index = start_line + 1
	file:write("$\n")
	local line = lines[index]
	while not string.find(line, "@end") and index < max_lines do
		file:write(line .. "\n")
		index = index + 1
		line = lines[index]
	end
	file:write("$\n")
	return index
end

---@param start_line integer line number
---@param lines table containing lines
---@param file file* to write
---@param max_lines integer max amount of lines
---@return integer
H.parse_link = function(start_line, lines, file, max_lines)
	local index = start_line
	local line = lines[index]
	line = line:gsub("{:(.*):(.*)}%[", "_")
	while not string.find(line, "%]") and index < max_lines do
		file:write(line .. "\n")
		index = index + 1
		line = lines[index]
	end
	line = line:gsub("%]", "_")
	file:write(line .. "\n")
	return index
end

H.header = function(l)
	local line = SH.trim_string(l)
	local prefix = SH.split_string(line, " ")[1]
	local len = string.len(prefix)
	local suffix = string.sub(line, len + 1, -1)
	return string.rep("=", len) .. suffix
end

H.list = function(l)
	local line = SH.trim_string(l)
	local prefix = SH.split_string(line, " ")[1]
	local len = string.len(prefix)
	local suffix = string.sub(line, len + 1, -1)
	if len == 1 then
		return line
	else
		return string.rep(" ", len - 1) .. "-" .. suffix
	end
end

---@param start_line integer line number
---@param lines table containing lines
---@param file file* to write
---@param max_lines integer max amount of lines
---@return integer
H.image = function(start_line, lines, file, _)
	local line = lines[start_line + 1]
	file:write("#image(" .. line .. ")")
	return start_line + 1
end

---@param start_line integer line number
---@param lines table containing lines
---@param file file* to write
---@param max_lines integer max amount of lines
---@return integer
H.typst = function(start_line, lines, file, max_lines)
	local index = start_line + 1
	local line = lines[index]
	file:write("\n")
	while not string.find(line, "@end") and index < max_lines do
		file:write(line .. "\n")
		index = index + 1
		line = lines[index]
	end
	file:write("\n")
	return index
end

---@param start_line integer line number
---@param lines table containing lines
---@param file file* to write
---@param max_lines integer max amount of lines
---@return integer
H.paragraph = function(start_line, lines, file, max_lines)
	local index = start_line
	local line = lines[index]
	local delim = ""
	while delim ~= "" do
		for i = 1, #line do
			local c = line:sub(i, i)
			if delim == "" then
				if c == "{" then
					if line:sub(i + 1, i + 1) == ":" then
						-- skip link
					else
						-- check link
					end
					delim = "}"
				elseif c == "$" then
					delim = "$"
					file:write("$")
				elseif c == "[" then
					delim = "]"
					file:write("_")
				else
					file:write(c)
				end
			elseif c ~= delim then
				i = i + 1
			else
				if delim ~= "}" then
					file:write(delim)
				end
				delim = ""
			end
		end
		index = index + 1
		line = lines[index]
	end
	file:write("\n")
	return index
end

H.get_cases = function()
	local cases = {
		["@document.meta"] = H.meta_data,
		["@code"] = H.code_block,
		["@math"] = H.math_block,
		["$$"] = H.definition,
		["@data"] = H.code_block,
		["@table"] = H.code_block,
		["@image"] = H.image,
		["@typst"] = H.typst,
	}
	return cases
end

return H
