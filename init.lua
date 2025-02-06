-- TODO
-- let ctrl+w exit the terminal (useful when split) and confirm there is no important functionality that ctrl+w does in the terminal
-- create a keyboard shortcut for creating a terminal in the split to the right and opening the directory from the buffer on the left. 
-- ctrl+z to enter/exit terminal
-- ideal terminal setup: use ctrl+z from anywhere to open the last terminal. If there are multiple display them in a list with a number to choose from. Once inside the terminal ctrl+z again goes back to the previous buffer. 
-- `:vsplit | term cd ~/path/to/file ; zsh` opens the terminal in a particular file

-- must be loaded before lazy.vim
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- lazy.vim package manager. Run :Lazy for settings
-- settings are in ~/.config/nvim/lua/config/lazy.lua
require("config.lazy")

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.rnu = true
vim.opt.hlsearch = false
vim.opt.hidden = true
vim.opt.splitright = true

-------------------------------------------------------------------------------
------------------------------------ THEME ------------------------------------
-------------------------------------------------------------------------------
vim.g.material_style = "darker"
vim.cmd 'colorscheme material'

-------------------------------------------------------------------------------
------------------------------------ MISC -------------------------------------
-------------------------------------------------------------------------------
-- see key-notation in :help
vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprev<CR>', { noremap = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("n", "<leader>r", ":%s/\\<<C-r><C-w>\\>//gc<Left><Left><Left>")
vim.keymap.set("n", "<leader>1", ':Ex<CR>')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>s', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>a', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

local action_state = require('telescope.actions.state')
local actions = require('telescope.actions')
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
         ["<CR>"] = function(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            local filepath = selection.path

              if filepath and filepath:match("%.pdf$") then
                vim.fn.jobstart({"open", filepath})
                actions.close(prompt_bufnr)
              else
                actions.select_default(prompt_bufnr)
              end
             end,
      },
      n = {
         ["<CR>"] = function(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            local filepath = selection.path

              if filepath and filepath:match("%.pdf$") then
                vim.fn.jobstart({"open", filepath})
                actions.close(prompt_bufnr)
              else
                actions.select_default(prompt_bufnr)
              end
         end,
         ["<Del>"] = actions.delete_buffer,
         ["<BS>"] = actions.delete_buffer,
      },
    },
  },
}

-------------------------------------------------------------------------------
---------------------------------- .txt/.md -----------------------------------
-------------------------------------------------------------------------------
-- Create an autocmd group to organize your autocmds
-- clear ensures these arent duplicated? if `source` multiple times
local text_file_group = vim.api.nvim_create_augroup("MarkdownAndTxtSettings", { clear = true })

-- Add autocmds for Markdown and plain text files
vim.api.nvim_create_autocmd("FileType", {
  group = text_file_group,
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.textwidth = 80
	-- todo figure out how to make this format on save
    vim.opt_local.formatoptions = "t"
    vim.opt_local.spell = true
  end,
})

-- not sure if this works, ideally underline mispelling in red.
vim.api.nvim_set_hl(0, "SpellBad", { underline = true, sp = "red" })

-------------------------------------------------------------------------------
-------------------------------------- .c --------------------------------------
-------------------------------------------------------------------------------
-- compile and run a c file with leader+enter
-- vim.api.nvim_set_keymap('n', '<leader>c', [[:w<CR>:!gcc % -o %:r<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>r', [[:w<CR>:!gcc % -o %:r && ./%:r<CR>]], { noremap = true, silent = true })
-- doesn't work but ok.
-- vim.api.nvim_set_keymap('n', '<leader>t', [[:w<CR>:terminal gcc % -o %:r && ./%:r<CR>]], { noremap = true, silent = true })

-- manually format, idk if this is the best way to do it.
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.c",
--   callback = function()
--     local pos = vim.api.nvim_win_get_cursor(0)
--     vim.cmd("normal! gggqG")
--     vim.api.nvim_win_set_cursor(0, pos)
--     vim.cmd("normal! zz")
--   end,
--   group = vim.api.nvim_create_augroup("format_on_save", { clear = true }),
-- })

--[[
LSP
nvim-lspconfig package + clangd installation required for this. See :help lsp
Formatting configured in ~/.clang-format. Run `clang-format -dump-config` to
see settings. This automatically overrides `gq` for formatting.
--]]
local lspconfig = require('lspconfig')
lspconfig.clangd.setup({})
vim.api.nvim_set_keymap('n', '<leader>j', '<Cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
