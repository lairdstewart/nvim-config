vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- lazy.vim package manager
require("config.lazy")

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.rnu = true
vim.opt.hlsearch = false
vim.opt.hidden = true

-------------------------------------------------------------------------------
------------------------------------ MISC -------------------------------------
-------------------------------------------------------------------------------
vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprev<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('t', '<Tab>', '<C-\\><C-n>:bnext<CR>', { noremap = true, silent = true })
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = "*",
--   callback = function()
--     if vim.bo.buftype == 'terminal' then
--       vim.cmd('startinsert')
--     end
--   end,
-- })

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
vim.api.nvim_set_keymap('n', '<leader>c', [[:w<CR>:!gcc % -o %:r<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>r', [[:w<CR>:!gcc % -o %:r && ./%:r<CR>]], { noremap = true, silent = true })
-- doesn't work but ok.
-- vim.api.nvim_set_keymap('n', '<leader>t', [[:w<CR>:terminal gcc % -o %:r && ./%:r<CR>]], { noremap = true, silent = true })

-- manually format, idk if this is the best way to do it.
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.c",
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd("normal! gggqG")
    vim.api.nvim_win_set_cursor(0, pos)
    vim.cmd("normal! zz")
  end,
  group = vim.api.nvim_create_augroup("format_on_save", { clear = true }),
})

-- LSP
-- nvim-lspconfig package + clangd installation required for this. Not sure why
-- I didn't have to do any of the setup required in :help lsp. Also, clangd was
-- already installed, I'm not sure where.
local lspconfig = require('lspconfig')
lspconfig.clangd.setup({})

-- Formatting manually? the lsp already (i think) sets gq)
--vim.api.nvim_create_autocmd("BufWritePre", {
--	pattern = "*.c",
--	command = "ClangFormat",
--	group = vim.api.nvim_create_augroup("clang_format_on_save", { clear = true }),
--})

