<p align="center">
  <h1 align="center">ainnoying.nvim</h1>
</p>

<img width="960" height="540" alt="ainnoying" src="https://github.com/user-attachments/assets/9c448e6b-1f91-41b3-bc4d-9cc20e6cdfe5" />


![Neovim](https://badgen.net/badge/Neovim/0.12%2B/green)
![Lua](https://badgen.net/badge/language/Lua/blue)
![License](https://badgen.net/static/license/MIT/blue)

<p align="center">
  A tiny (<200 LOC) plugin to chat with llm in a way that is less disruptive to your flow.
</p>

## Features
- Invoke AI directly in your codebase, review the results when you're ready.
- Create your own interactions to tailor the experience for yourself

## Requirements
- Neovim 0.12+
- Codecompanion 19.+
- Blink.cmp 1.10+

## Installation

Install with your preffered package manager. For lazy.nvim:
```lua
{ "khaninm/ainnoying.nvim" }
```

## Quickstart
```lua
local ainnoying = require("ainnoying").setup({})

-- set keybinds
vim.keymap.set('n', '<leader>ai', function() ainnoying.open_hidden_chat end)
```

register a blink.cmp source
```lua
{
    'saghen/blink.cmp',
    dependencies = {
        'khaninm/ainnoying.nvim',
        -- ...
    },
    opts = {
        sources = {
            -- Add 'ainnoying' to the list
            default = { 'ainnoying', 'lsp', 'buffer' },
            providers = {
                ainnoying = {
                    module = 'ainnoying.blink',
                    name = 'ainnoying',
                    -- Add score offset to show completions at the top of the list
                    score_offset = 1000,
                }
            },
        }
    }
}
```
 
## Defaults
```lua
-- if blink.cmp should suggest completions while deliting symbols
suggest_on_delete = true,
-- highlight comments with queries to make them more visible
highlight = true,
codecompanion_tool_template = "Use @{%s}. ",
strategies = {
  {
    -- change the way completions are shown in blink.cmp window
    blink_label_prefix = "Ask AI: ",
    blink_label_doc = "Ask AI and come back to the answer whenever you want",
    -- what lines are counted as AI invokations
    -- has to contain two groups: whitespaces and the text of the query
    parser_expression = "^(%s*)%?%s*(.+)",
    codecompanion_message_template = "Answer the following question: %s",
    codecompanion_tools = {},
    codecompanion_context = {},
    -- wether or not to include the current buffer in codecompanion context
    codecompanion_include_buffer = false,
    -- turn off if you want to edit request before sending it
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
```

## Acknowledgements
- [Ingur Veken](https://github.com/ingur) for his floaty.nvim minimalist approach that inspired this plugin
- [Oli](https://github.com/olimorris) for the beautiful Codecompanion plugin
- [Liam Dyer](https://github.com/saghen) for the blink.cmp and it's super readable docs
