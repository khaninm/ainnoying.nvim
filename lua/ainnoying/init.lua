local M = {}

M.config = {
	suggest_on_delete = true,
	highlight = true,
	codecompanion_tool_template = "Use @{%s}. ",
	strategies = {
		{
			blink_label_prefix = "Ask AI: ",
			blink_label_doc = "Ask AI and come back to the answer whenever you want",
			parser_expression = "^(%s*)%?%s*(.+)",
			codecompanion_message_template = "Answer the following question: %s",
			codecompanion_tools = {},
			codecompanion_context = {},
			codecompanion_include_buffer = false,
			codecompanion_auto_submit = true,
		},
		{
			blink_label_prefix = "Ask AI: ",
			blink_label_doc = "Ask AI about your code",
			parser_expression = "^(%s*)%?%s*(.+)",
			codecompanion_message_template = "Answer the following question: %s",
			codecompanion_tools = {},
			codecompanion_context = {},
			codecompanion_include_buffer = true,
			codecompanion_auto_submit = true,
		},
		{
			blink_label_prefix = "Write code:",
			blink_label_doc = "AI codes for you",
			parser_expression = "^(%s*)%!%s*(.+)",
			codecompanion_message_template = "%s",
			codecompanion_tools = { "insert_edit_into_file" },
			codecompanion_context = {},
			codecompanion_include_buffer = true,
			codecompanion_auto_submit = true,
		},
	}
}
M.chats = {}

M.new_silent_chat = function(completion_item)
	local codecompanion = require("codecompanion")

	local buffers = ""
	if completion_item.strategy.codecompanion_include_buffer then
		buffers = buffers .. ("#{buffer:%s} "):format(vim.api.nvim_buf_get_name(0))
	end

	for _, file in ipairs(completion_item.strategy.codecompanion_context) do
		buffers = buffers .. ("#{buffer:%s} "):format(file)
	end

	local tools = ""
	for _, tool in ipairs(completion_item.strategy.codecompanion_tools) do
		tools = tools .. M.config.codecompanion_tool_template:format(tool)
	end

	local codecompanion_prefix = buffers .. tools
	local codecompanion_query = completion_item.strategy.codecompanion_message_template:format(completion_item.query)

	local hidden_chat = codecompanion.chat({
		hidden = true,
		auto_submit = completion_item.strategy.codecompanion_auto_submit,
		messages = { { role = "user", content = codecompanion_prefix .. codecompanion_query }, }
	})

	if hidden_chat == nil or hidden_chat.id == nil then
		return
	end

	table.insert(M.chats,
		{ chat = hidden_chat, completion = completion_item.label, query = completion_item.strategy.query })
end

M.open_hidden_chat = function()
	local current_line = vim.api.nvim_get_current_line()

	for _, chat in ipairs(M.chats) do
		if current_line == chat.completion then
			chat.chat.ui:open()
		end
	end
end

M.setup = function(opts)
	vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
