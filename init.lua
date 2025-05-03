-- make replace <leader>r start from current and go down
-- alt+s equivalent (see and navigate method declarations)
-- map gj (holding down g already) to map to g+j
-- javadoc coloring doesn't work with spaces.
-- tab doesn't work !!!
-- try out https://github.com/SirVer/ultisnips
-- make :w create directories/folders as necessary
-- include git +- symbols in left column
-- don't close help buffer when leaving
-- oil --> term is broken
-- make help and oil full screen and not disrupt splits when you return
-- when opening terminal from anywhere go into insert mode automatically
-- oil can't delete hidden files?
-- store last_normal_buffer
-- can't open links with gx from markdown. think b.c. I'm not using netrw

-- iTerm2 mappings:
-- cmd-n to <M-;>
-- cmd-shift-n to <M-q>

-- must be loaded before lazy.vim
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- lazy.vim package manager. Run :Lazy for settings
-- settings are in ~/.config/nvim/lua/config/lazy.lua
require("config.lazy")

-- for returning to the latest buffer from oil/terminal
vim.g.last_normal_buffer_num = 0

local onBufLeave = function()
  -- if not Oil, help, or term, save buffer
  if vim.bo.buftype ~= "help" and vim.bo.buftype ~= "term" then
    print("save buffer num")
  end
end

-- OIL
vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function()
    vim.keymap.set("n", "<CR>", function()
      local oil = require("oil")
      local entry = oil.get_cursor_entry()
      local name = entry and entry.name or ""

      if name:match("%.png$") or name:match("%.pdf$") or name:match("%.jpg$") then
          print("hello2")
        require("oil.actions").open_external.callback()
      else
        require("oil.actions").select.callback()
      end
    end, { buffer = true })
  end,
})

-- open links without netrw
-- vim.keymap.set("n", "gx", function()
--   local url = vim.fn.expand("<cWORD>")
--   vim.fn.jobstart({ "open", url }, { detach = true })
-- end, { silent = true })
-- open links with netrw (attempt 2)
vim.g.netrw_nogx = 1
vim.keymap.set('n', 'gx', function()
  local url = vim.fn.expand('<cfile>')
  if url ~= '' then
    vim.fn.jobstart({'open', url}, {detach = true})
  end
end, {desc = 'Open URL under cursor (macOS)'})

--local function clever_enter()
--  local col = vim.fn.col('.') - 1
--  local line = vim.fn.getline('.')
--  if line:sub(1, col):match("^%s*$") then
--    return vim.api.nvim_replace_termcodes("<CR>", true, true, true)
--  else
--    return vim.api.nvim_replace_termcodes("<C-Y>", true, true, true)
--  end
--end
--
--vim.keymap.set("i", "<CR>", clever_enter, { expr = true, noremap = true })



-------------------------------------------------------------------------------
------------------------------------ JDTLS -------------------------------------
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
        require("config.ftplugin.java")
    end,
})

-------------------------------------------------------------------------------
-------------------------------- DIAGNOSTICS ----------------------------------
-------------------------------------------------------------------------------
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.HINT] = '',
            [vim.diagnostic.severity.INFO] = '',
        },
    }
})

-- abbreviations 
vim.cmd("iabbrev sout System.out.println();")
vim.cmd("iabbrev souf System.out.printf();")

-------------------------------------------------------------------------------
------------------------------------ HELP -------------------------------------
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Don't open help buffer in split, exit with Esc",
  callback = function()
    if vim.bo.buftype == "help" then
      vim.cmd.wincmd("o")
      vim.keymap.set({ "n" }, "<Esc>", function()
        vim.cmd("b#")
      end, { buffer = 0 })
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
    show_hidden = true,
  },
  keymaps = {
    ["<ESC>"] = { "actions.close", mode = "n" },
    ["<M-j>"] = { "actions.close", mode = "n" },
    -- todo open pdfs and pngs
  },
})

vim.keymap.set("n", "<leader>j", "<C-\\><C-n>:Oil .<CR>")
vim.keymap.set("n", "-", ":Oil<CR>")

-------------------------------------------------------------------------------
------------------------------------ OPTS -------------------------------------
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
vim.opt.lbr = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪"
vim.opt.formatoptions = "jcrql"
-- vim.opt.colorcolumn = "80" -- todo turn off in OIL

-------------------------------------------------------------------------------
------------------------------------ THEME ------------------------------------
-- vim.cmd("colorscheme material")
-------------------------------------------------------------------------------
-- vim.g.material_style = "darker"
vim.cmd("colorscheme tokyonight")

-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
-- vim.api.nvim_set_hl(0, "FoldColumn", { bg = "none" })

-------------------------------------------------------------------------------
---------------------------------- KEYMAPS ------------------------------------
-------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>t", ":ClangFormat<CR>")
vim.keymap.set("n", "<leader>c", ":CompileAndRun<CR>")
-- Disable clipboard copying when pasting in visual mode
vim.api.nvim_set_keymap('v', 'p', '"_dP', { noremap = true, silent = true })
vim.keymap.set( "n", "<leader>l", "<C-i>")
vim.keymap.set("n", "<leader>h", "<C-o>")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("n", "<leader>r", ":%s/\\<<C-r><C-w>\\>//gc<Left><Left><Left>")
-- vim.keymap.set("n", "<leader>r", ":%s/")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')
vim.keymap.set("n", "<leader>p", '"+p')
vim.keymap.set("v", "<leader>p", '"+p')
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')
vim.keymap.set({"n", "i", "v"}, "<C-/>", ":Commentary<CR>", {silent=true})
-- vim.keymap.set("n", "<leader>e", vim.diagnostic.goto_next)

-------------------------------------------------------------------------------
-------------------------------- USER COMMANDS --------------------------------
-------------------------------------------------------------------------------
vim.api.nvim_create_user_command('CompileAndRun', function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%')

  if filetype == 'c' then
    local output_name = vim.fn.expand('%:p:h') .. '/' .. vim.fn.expand('%:t:r')
    vim.cmd('w')
    vim.cmd('terminal gcc "' .. filename .. '" -o "' .. output_name .. '" && "' .. output_name .. '"')
  elseif filetype == 'python' then
    vim.cmd('w')
    vim.cmd('terminal python3 "' .. filename .. '"')
  else
    print("File type not recognized!")
  end
end, { desc = "Compile and run current file" })

-------------------------------------------------------------------------------
------------------------------------ TERM -------------------------------------
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Set terminal-normal mode specific commands",
  group = vim.api.nvim_create_augroup("term-normal-commands", { clear = true }),
  callback = function()
    vim.keymap.set({ "n" }, "<C-n>", function()
      vim.cmd("b#")
      vim.g.netrw_buffer_on_entry = nil
    end, { silent = true, buffer = 0 })
  end,
})

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>")
-- TODO not working anymore
vim.keymap.set("n", "<leader>;", function()
  vim.cmd("redir @a | silent ls | redir END")
  local output = vim.fn.system("grep term", vim.fn.getreg("a"))
  local first_line = vim.split(output, "\n")[1]
  local bufnr = tonumber(vim.fn.trim(vim.fn.matchstr(first_line, [[\v\s*\d+]])))
  if bufnr then
    vim.cmd("buffer " .. bufnr)
  else
    vim.cmd("term")
  end
  vim.cmd("normal! i")
end, { noremap = true, silent = true })

-------------------------------------------------------------------------------
--------------------------------- TELESCOPE -----------------------------------
-------------------------------------------------------------------------------
local builtin = require("telescope.builtin")
vim.keymap.set("n", '<leader>f', builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>a", builtin.buffers, { desc = "Telescope buffers" })
-- vim.keymap.set('n', '<leader>f', builtin.lsp_references, {desc = "Telescope find references"});
vim.keymap.set("n", "<leader>e", function()
  builtin.diagnostics({ bufnr = 0 })
end, { desc = "Show diagnostics for current buffer" })

-- vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
-- vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
require("telescope").setup({
  pickers = {
    buffers = {
      ignore_current_buffer = true,
      sort_mru = true,
    },
  },
  defaults = {
    -- layout_strategy = 'vertical',
    layout_config = {
      height = 0.99,
      width = 0.99,
      -- prompt_position = "top"
    },
    mappings = {
      i = {
        ["<CR>"] = function(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local filepath = selection.path

          if filepath and filepath:match("%.pdf$") then
            vim.fn.jobstart({ "open", filepath })
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
            vim.fn.jobstart({ "open", filepath })
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
})

-------------------------------------------------------------------------------
------------------------------------ .py -------------------------------------
-------------------------------------------------------------------------------

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
------------------------------------- .c --------------------------------------
-------------------------------------------------------------------------------
-- compile and run
