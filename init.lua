vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- Netrw config
vim.g.netrw_keepdir = 0
vim.g.netrw_winsize = 20
vim.g.netrw_banner = 0

-- Decrease update time
vim.o.updatetime = 150

vim.g.timeoutlen = 300
vim.g.timeout = false

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true
-- Show line number on cursor line and relative numbers up and down
vim.wo.number = true
vim.wo.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.colorcolumn = "120"

-- Nvim-Tree is required this
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup('plugins')

--
-- REMAP
--

-- vim.keymap.set('n', '<C-1>', vim.cmd.Lex);
-- vim.keymap.set('n', '<leader>E', ':Lexplore %:p:h<CR>');
-- vim.keymap.set('n', '<C-2>', ':Lexplore %:p:h<CR>');

-- window navigation
vim.keymap.set('n', '<ca-Right>', '<CMD>wincmd l<CR>', { noremap = true });
vim.keymap.set('n', '<ca-Down>', '<CMD>wincmd j<CR>', { noremap = true });
vim.keymap.set('n', '<ca-Left>', '<CMD>wincmd h<CR>', { noremap = true });
vim.keymap.set('n', '<ca-Up>', '<CMD>wincmd k<CR>', { noremap = true });
vim.keymap.set('t', '<ca-Right>', '<CMD>wincmd l<CR>', { noremap = true });
vim.keymap.set('t', '<ca-Down>', '<CMD>wincmd j<CR>', { noremap = true });
vim.keymap.set('t', '<ca-Left>', '<CMD>wincmd h<CR>', { noremap = true });
vim.keymap.set('t', '<ca-Up>', '<CMD>wincmd k<CR>', { noremap = true });

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>`', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
vim.keymap.set('n', '<leader>1', vim.diagnostic.open_float, { desc = 'Open diagnostics list' })
vim.keymap.set('n', '<leader>2', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Use LspAttach autocommand to only map the following keys
-- after the language server atTaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<A-F>', function()
            vim.lsp.buf.format { async = true }
        end, opts)
        vim.keymap.set('n', '<A-f><A-f>', function()
            vim.lsp.buf.format { async = true }
        end, opts)
        vim.keymap.set('i', '<A-f><A-f>', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})
