local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.mapleader = " "
require("lazy").setup({
  -- The fancy start screen for Vim
  "mhinz/vim-startify",
  -- A tree explorer plugin for Vim
  "preservim/nerdtree",
  -- Grep search tools integration with Vim
  "vim-scripts/grep.vim",
  -- Smart and powerful comment plugin for neovim
  "numToStr/Comment.nvim",
  -- Vim bookmark plugin
  "MattesGroeger/vim-bookmarks",
  -- A Git wrapper so awesome, it should be illegal
  "tpope/vim-fugitive",
  -- A Vim plugin which shows git diff markers in the sign column
  "airblade/vim-gitgutter",
  -- A command-line fuzzy finder
  {"junegunn/fzf", build = "./install --bin"},
  -- Quickstart configs for Nvim LSP
  "neovim/nvim-lspconfig",
  -- Nvim Treesitter configurations and abstraction layer
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
  -- WebAssembly filetype support for Vim
  "rhysd/vim-wasm",
  -- Vim filetype support for LLVM
  "rhysd/vim-llvm",
  -- Colorscheme inspired by the colors of the painting by Katsushika Hokusai
  "rebelot/kanagawa.nvim",
  -- A GUI library for Neovim plugin developers
  {"ray-x/guihua.lua", build = "cd lua/fzy && make"},
  -- Make Vim handle line and column numbers in file names with a minimum of
  -- fuss.
  "wsdjeg/vim-fetch",
})

require('kanagawa').setup({
    keywordStyle = { italic = false },
    statementStyle = { bold = false },
    colors = {
        theme = {
            all = {
                ui = {
                    fg = "#c7c7c7",
                    fg_dim = "#a0a0a0",
                    nontext = "#606060",
                    bg = "#000000",
                    bg_p1 = "#09090c",
                    bg_gutter = "#000000",
                },
                syn = {
                    comment = "#888888",
                },
                vcs = {
                    added = "#a6e22e",
                    removed = "#f02020",
                    changed = "#cc00ff",
                },
            },
        },
    },
    overrides = function(colors)
        local theme = colors.theme
        local makeDiagColor = function(color)
            local c = require("kanagawa.lib.color")
            return {
                fg = color, bg = c(color):blend(theme.ui.bg, 0.98):to_hex()
            }
        end
        return {
            -- boolean literals
            ["@boolean"] = {
                fg = theme.syn.constant, bg = theme.ui.bg, bold = false
            },
            -- operators that are English words (e.g. `and`, `or`)
            ["@keyword.operator"] = {
                fg = theme.syn.operator, bg = theme.ui.bg, bold = false
            },
            -- error-type comments (e.g. ERROR, FIXME, DEPRECATED)
            ["@comment.error"] = {
                fg = theme.syn.comment, bg = theme.ui.bg, bold = true
            },
            -- warning-type comments (e.g. WARNING, FIX, HACK)
            ["@comment.warning"] = {
                fg = theme.syn.comment, bg = theme.ui.bg, bold = true
            },
            -- todo-type comments (e.g. TODO, WIP)
            ["@comment.todo"] = {
                fg = theme.syn.comment, bg = theme.ui.bg, bold = true
            },
            -- note-type comments (e.g. NOTE, INFO, XXX)
            ["@comment.note"] = {
                fg = theme.syn.comment, bg = theme.ui.bg, bold = true
            },
            -- Tint background of diagnostic messages with their foreground color
            DiagnosticVirtualLinesError = makeDiagColor(theme.diag.error),
            DiagnosticVirtualLinesWarn  = makeDiagColor(theme.diag.warning),
            DiagnosticVirtualLinesInfo  = makeDiagColor(theme.diag.info),
            DiagnosticVirtualLinesHint  = makeDiagColor(theme.diag.hint),
        }
    end,
})

vim.cmd.colorscheme('kanagawa')

vim.lsp.config.clangd = {
    cmd = { 'clangd', '--background-index' },
    root_markers = { 'compile_commands.json', 'compile_flags.txt' },
    filetypes = { 'c', 'cpp' },
}

vim.lsp.enable({'clangd'})

local treesitter = require('nvim-treesitter.configs')
treesitter.setup({
    highlight = {
        enable = true,
    },
})

vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = true,
    signs = false,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

vim.keymap.set("n", "<C-[>", vim.lsp.buf.incoming_calls,
    { desc = "LSP incoming calls" })
vim.keymap.set("n", "<C-,>", "<cmd>cprev<CR>",
    { desc = "Previous quickfix item" })
vim.keymap.set("n", "<C-.>", "<cmd>cnext<CR>",
    { desc = "Next quickfix item" })

vim.api.nvim_set_hl(0, "QuickFixLine", { link = "Visual" })

local method = "callHierarchy/incomingCalls"
local handler = vim.lsp.handlers and vim.lsp.handlers[method]
if handler then
    vim.lsp.handlers[method] = function(err, result, ctx, config)
        handler(err, result, ctx, config)
        if not err and result ~= nil then
            vim.schedule(function()
                if #vim.fn.getqflist() > 0 then
                    pcall(vim.cmd, "cclose")
                    vim.cmd("cfirst")
                end
            end)
        end
    end
end
