local ainnoying = require("ainnoying")

-- the highlighting part

local ns = vim.api.nvim_create_namespace("ainnoying")
vim.api.nvim_set_hl(0, "ainnoying", { link = "search" })

local function highlight_line(row, offset, cutoff)
	vim.highlight.range(0, ns, "ainnoying", { row, offset }, { row, cutoff }, { regtype = 'v' })
end

-- the blink.cmp source part

local source = {}

function source.new(opts)
	-- honestly, no clue what it does, just copy pasted it from `blink.cmp` boilerplate
	local self = setmetatable({}, { __index = source })
	self.opts = opts
	return self
end

function source:enabled()
	local line = vim.api.nvim_get_current_line()
	for _, strategy in ipairs(ainnoying.config.strategies) do
		if line:match(strategy.parser_expression) then
			return true
		end
	end

	return false
end

function source:get_completions(ctx, callback)
	local commentstring = vim.bo.commentstring
	if commentstring == '' or commentstring == nil then
		commentstring = '# %s'
	end

	local items = {}

	for _, strategy in ipairs(ainnoying.config.strategies) do
		if ctx.line:match(strategy.parser_expression) then
			local whitespace, query = ctx.line:match(strategy.parser_expression)
			local completion = whitespace .. commentstring:format(strategy.blink_label_prefix .. query)

			table.insert(items, {
				label = completion,
				textEdit = {
					newText = completion,
					range = {
						['start'] = { line = ctx.bounds.line_number - 1, character = 0 },
						['end'] = { line = ctx.bounds.line_number - 1, character = ctx.bounds.length + completion:len() - 1 },
					},
				},
				documentation = {
					kind = 'markdown',
					value = strategy.blink_label_doc
				},
				whitespace_len = #whitespace,
				completion_len = #completion,
				query = query,
				strategy = strategy,
			})
		end
	end

	callback({
		items = items,
		is_incomplete_backward = ainnoying.config.suggest_on_delete,
		is_incomplete_forward = true,
	})

	return function() end
end

function source:get_trigger_characters() return { '.', '?', '!' } end

function source:execute(ctx, item, callback, default_implementation)
	-- invoke AI
	ainnoying.new_silent_chat(item)

	-- default accept
	default_implementation()
	callback()

	-- highlighting
	if ainnoying.config.highlight then
		highlight_line(ctx.bounds.line_number - 1, item.whitespace_len, item.completion_len)
	end
end

return source
