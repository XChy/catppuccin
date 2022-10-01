local M = {}

local function get_integrations()
	local integrations = cnf["integrations"]
	local final_integrations = {}

	for integration in pairs(integrations) do
		local cot = false
		if type(integrations[integration]) == "table" then
			if integrations[integration]["enabled"] == true then
				cot = true
			end
		else
			if integrations[integration] == true then
				cot = true
			end
		end

		if cot then
			final_integrations = vim.tbl_deep_extend(
				"force",
				final_integrations,
				require("catppuccin.groups.integrations." .. integration).get()
			)
		end
	end

	return final_integrations
end

function M.apply(flavour)
	flavour = flavour or vim.g.catppuccin_flavour
	-- Borrowing global var
	_G._cnf = cnf
	_G._cp = cp
	_G._ucolors = ucolors

	_G.cnf = require("catppuccin.config").options
	_G.cp = require("catppuccin.palettes").get_palette(flavour)
	_G.ucolors = require("catppuccin.utils.colors")

	cp.none = "NONE"
	cp.dim = require("catppuccin.lib.ui").dim()

	local theme = {}
	theme.properties = require("catppuccin.groups.properties").get() -- nvim settings
	theme.syntax = require("catppuccin.groups.syntax").get()
	theme.editor = require("catppuccin.groups.editor").get()
	theme.integrations = get_integrations() -- plugins
	theme.terminal = require("catppuccin.groups.terminal").get() -- terminal colors
	local user_highlights = require("catppuccin.config").options.highlight_overrides
	theme.custom_highlights = vim.tbl_deep_extend("keep", user_highlights[flavour] or {}, user_highlights.all or {})

	-- Returning global var
	_G.cnf = _G._cnf
	_G.cp = _G._cp
	_G.ucolors = _G._ucolors

	return theme
end

return M
