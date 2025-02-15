-- must be loaded before lazy.vim
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- lazy.vim package manager. Run :Lazy for settings
-- settings are in ~/.config/nvim/lua/config/lazy.lua
require("config.lazy")

-------------------------------------------------------------------------------
------------------------------------- OIL -------------------------------------
-------------------------------------------------------------------------------
require("oil").setup({
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
        -- show_hidden = true
    }, 
    keymaps = {
        ["<ESC>"] = { "actions.close", mode = "n" },
        ["<M-j>"] = { "actions.close", mode = "n" },
    }
})
vim.keymap.set({'n', 'i'}, '<M-j>', ":Oil<CR>")
vim.keymap.set('t', '<M-j>', '<C-\\><C-n>:Oil<CR>')
-- todo: terminal --> oil --> <M-j> returns to terminal. It should go back to the og buffer
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

-------------------------------------------------------------------------------
------------------------------------ THEME ------------------------------------
-------------------------------------------------------------------------------
vim.g.material_style = "darker"
vim.cmd 'colorscheme material'

-------------------------------------------------------------------------------
------------------------------------ NETRW ------------------------------------
-------------------------------------------------------------------------------
-- todo https://vonheikemen.github.io/devlog/tools/using-netrw-vim-builtin-file-explorer/
vim.g.netrw_list_hide = [[^\.\.\=/\=$]]
vim.g.netrw_buffer_on_entry = nil
vim.g.netrw_banner = 0
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'netrw',
    callback = function()
        if not vim.g.netrw_buffer_on_entry then
            vim.g.netrw_buffer_on_entry = vim.fn.bufnr('#')
        end

        vim.keymap.set('n', 'n', '%', {remap = true, buffer = true})
        vim.keymap.set('n', 'r', 'R', {remap = true, buffer = true})
        vim.keymap.set('n', 'h', '-', {remap = true, buffer = true})
        vim.keymap.set('n', 'l', '<CR>', {remap = true, buffer = true})
        vim.keymap.set('n', '<M-j>', function()
            if vim.fn.bufexists(vim.g.netrw_buffer_on_entry) == 1 then
                vim.cmd('buffer ' .. vim.g.netrw_buffer_on_entry)
            end
            -- todo need to do this if selecting a file as well ... 
            vim.g.netrw_buffer_on_entry = nil
        end, {remap = true, buffer = true})
        vim.keymap.set('n', '<Esc>', function()
            if vim.fn.bufexists(vim.g.netrw_buffer_on_entry) == 1 then
                vim.cmd('buffer ' .. vim.g.netrw_buffer_on_entry)
            end
            -- todo need to do this if selecting a file as well ... 
            vim.g.netrw_buffer_on_entry = nil
        end, {remap = true, buffer = true})
    end
})

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
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

-------------------------------------------------------------------------------
------------------------------------ TERM -------------------------------------
-------------------------------------------------------------------------------
-- TODO:
-- 1. <M-;> doesn't return from normal mode in the temrinal. need to figure
-- out a way to specify that mode in particular. I can't specify 
-- d
-- 2. I can't open netrw from normal mode in the terminal
-- 3. If I open netrw from 't', then press <Esc> I'm not returned to my OG buffer
-- 4. if I open a file from netrw the global buffer variable isn't set to nil correctly
function OpenExplorer()
    vim.cmd("enew")
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.buflisted = false
    vim.cmd("Ex")
end

-- todo: going from terminal to explorer and back and forth doesn't store the last "real" buffer correctly
-- vim.keymap.set({'t'}, '<M-j>', [[<C-\><C-n>:lua OpenExplorer()<CR>]], { noremap = true, silent = true })

vim.keymap.set({'t'}, '<C-o>', function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true), 'n', false)
  vim.cmd('b#')
  vim.g.netrw_buffer_on_entry = nil
end, { noremap = true, silent = true })

-- vim.keymap.set("n", "<M-;>", function() -- windows
vim.keymap.set({'n', 'i'}, "<C-o>", function() -- mac from iterm command+;
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

-- Configure Pyright for Python
-- installed pyright via homebrew
lspconfig.pyright.setup {
  on_attach = function(client, bufnr)
    -- Keybindings for LSP features
    local opts = { noremap = true, silent = true, buffer = bufnr }
    -- local keymap = vim.api.nvim_set_keymap

    -- LSP key mappings
    -- keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    -- keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
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


