-- mapped <C-o> to <M-;> in iTerm2

-- todo: oil can't delete hidden files?
-- todo: C-o is go back, can't use that for reamp ; 

-- must be loaded before lazy.vim
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- lazy.vim package manager. Run :Lazy for settings
-- settings are in ~/.config/nvim/lua/config/lazy.lua
require("config.lazy")

-- for returning to the latest buffer from oil/terminal
vim.g.last_normal_buffer = nil

-------------------------------------------------------------------------------
------------------------------------ HELP -------------------------------------
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Don't open help buffer in split, exit with Esc",
  callback = function()
    if vim.bo.buftype == "help" then
      vim.cmd.wincmd("o")
      vim.keymap.set({"n"}, "<Esc>", function() vim.cmd('b#') end, { buffer = 0 })
    end
  end,
})

-------------------------------------------------------------------------------
------------------------------------- OIL -------------------------------------
-------------------------------------------------------------------------------
require("oil").setup({
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
        show_hidden = true
    }, 
    keymaps = {
        ["<ESC>"] = { "actions.close", mode = "n" },
        ["<M-j>"] = { "actions.close", mode = "n" },
    }
})

vim.keymap.set({'n', 'i', 't'}, '<M-j>', '<C-\\><C-n>:Oil .<CR>')
vim.keymap.set('n', '-', ":Oil<CR>")

-------------------------------------------------------------------------------
------------------------------------ MISC -------------------------------------
-------------------------------------------------------------------------------
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.rnu = true
vim.opt.hlsearch = false
vim.opt.hidden = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-------------------------------------------------------------------------------
------------------------------------ THEME ------------------------------------
-------------------------------------------------------------------------------
vim.g.material_style = "darker"
vim.cmd 'colorscheme material'

-------------------------------------------------------------------------------
------------------------------------ MISC -------------------------------------
-------------------------------------------------------------------------------
--vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', { noremap = true })
--vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprev<CR>', { noremap = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("n", "<leader>r", ":%s/\\<<C-r><C-w>\\>//gc<Left><Left><Left>")
vim.keymap.set("n", "<C-u>", '<C-u>zz')
vim.keymap.set("n", "<C-d>", '<C-d>zz')
vim.keymap.set("n", "n", 'nzz')
vim.keymap.set("n", "N", 'Nzz')
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")
vim.keymap.set("n", "<leader>p", "\"+p")
vim.keymap.set("v", "<leader>p", "\"+p")
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

-------------------------------------------------------------------------------
------------------------------------ TERM -------------------------------------
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Set terminal-normal mode specific commands',
  group = vim.api.nvim_create_augroup('term-normal-commands', { clear = true }),
  callback = function()
    vim.keymap.set({"n"}, "<C-o>", function()
      vim.cmd('b#')
      vim.g.netrw_buffer_on_entry = nil
      end, { silent = true, buffer = 0 })
  end,
})

vim.keymap.set('t', '<C-o>', '<C-\\><C-n>:b#<CR>')

-- vim.keymap.set("n", "<M-;>", function() -- windows
vim.keymap.set({'n', 'i'}, "<C-o>", function()
    vim.cmd("redir @a | silent ls | redir END")
    local output = vim.fn.system("grep term", vim.fn.getreg("a"))
    local first_line = vim.split(output, "\n")[1]
    local bufnr = tonumber(vim.fn.trim(vim.fn.matchstr(first_line, [[\v\s*\d+]])))
    if (bufnr) then
        vim.cmd("buffer " .. bufnr)
    else
        vim.cmd("term")
    end
    vim.cmd("normal! i")
end, { noremap = true, silent = true })

-------------------------------------------------------------------------------
--------------------------------- TELESCOPE -----------------------------------
-------------------------------------------------------------------------------
local builtin = require('telescope.builtin')
vim.keymap.set({'n', 'i', 't'}, '<M-f>', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set({'n', 'i', 't'}, '<M-a>', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

local action_state = require('telescope.actions.state')
local actions = require('telescope.actions')
require('telescope').setup{
  pickers = {
    buffers = {
      ignore_current_buffer = true,
    },
  },
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

-- todo: removed since it messes up documentation presentation
-- vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
--   pattern = { '*.txt', '*.md' },
--   callback = function()
--     vim.opt_local.wrap = true
--     vim.opt_local.lbr = true
--     vim.opt_local.spell = true
--     if vim.fn.winnr '$' == 1 then
--       vim.cmd 'vsplit void.txt'
--       vim.cmd 'wincmd h'
--       vim.cmd 'vertical resize 83'
--     end
--   end,
-- })

-- vim.api.nvim_create_autocmd({ 'BufWinLeave' }, {
--   pattern = { '*.txt', '*md' },
--   callback = function()
--     vim.cmd 'wincmd o'
--   end,
-- })

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

-- Configure Pyright for Python
-- installed pyright via homebrew
lspconfig.pyright.setup {
  on_attach = function(client, bufnr)
    -- Keybindings for LSP features
    local opts = { noremap = true, silent = true, buffer = bufnr }
    -- local keymap = vim.api.nvim_set_keymap

    -- LSP key mappings
    keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    -- keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    -- keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    -- keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    -- keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

    -- Format on save
    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --   buffer = bufnr,
    --   callback = function()
    --     vim.lsp.buf.format({ async = false })
    --   end,
    -- })
  end,

  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic", -- Change to "strict" for stricter type checking
      },
    },
  },
}


