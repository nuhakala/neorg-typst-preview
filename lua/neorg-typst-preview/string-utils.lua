local H = {}

---Split string
---@param input string The string to split.
---@param sep string The separator string.
---@return table # Table containing the split pieces
H.split_string = function(input, sep)
	if sep == nil then
		sep = "%s"
	end

	-- Add space to empty columns to fix formatting
	input = input:gsub(sep, sep .. " ")
	input = H.trim_string(input)

	local t = {}
	for str in string.gmatch(input, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

---Trim spaces from beginning and end of string
---@param s string The string to trim.
---@return string # The trimmed string and number of whitespace in beginning
H.trim_string = function(s)
	s = s ~= nil and s or ""
	return s:match("^%s*(.-)%s*$")
end

H.get_after = function(s, sep)
	local t = H.split_string(s, sep)
	return H.trim_string(t[1])
end

H.startswith = function(line, pattern)
	local l = H.trim_string(line)
    return string.sub(l, 1, #pattern) == pattern
end

return H
