-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
    -- clangd = {},
    gopls = {},
    pyright = {
    },
    rust_analyzer = {
        diagnostics = {
            enable = true,
        },
        inlayHints = { parameterHints = true }
    },
    -- diagnosticls = {},
    -- tsserver = {},
    html = { filetypes = { 'html', 'twig', 'hbs' } },
    cssls = {},
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
    --phpactor = {
    --    init_options = {
    --        ["language_server_phpstan.enabled"] = true,
    --        ["language_server_psalm.enabled"] = true,
    --        ["language_server_php_cs_fixer.enabled"] = true,
    --        ["php_code_sniffer.enabled"] = true,
    --        ["prophecy.enabled"] = true,
    --        ["language_server_worse_reflection.inlay_hints.enable"] = true,
    --        ["language_server_worse_reflection.inlay_hints.types"] = true

    --    }
    --},
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
}

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    -- nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('<C-.>', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })

    -- Inlay Hints
    vim.api.nvim_buf_create_user_command(bufnr, 'InlayHintEnable', function(_)
        vim.lsp.inlay_hint.enable(bufnr, true)
    end, { desc = 'Enable InlayHints' })
    vim.api.nvim_buf_create_user_command(bufnr, 'InlayHintDisable', function(_)
        vim.lsp.inlay_hint.enable(bufnr, false)
    end, { desc = 'Disable InlayHints' })
    vim.api.nvim_buf_create_user_command(bufnr, 'InlayHintToggle', function(_)
        vim.lsp.inlay_hint.enable(bufnr, not vim.lsp.inlay_hint.is_enabled(bufnr))
    end, { desc = 'Disable InlayHints' })
    nmap('<A-h>', "<CMD>InlayHintToggle<CR>", '[I]nlay [H]int [T]oggle')
end

local lspconfig = require 'lspconfig'
local configs = require 'lspconfig.configs'

if not configs.php_ls then
    configs.php_ls = {
        default_config = {
            cmd = { '/home/eksandral/projects/php-ls/target/debug/server' },
            root_dir = lspconfig.util.root_pattern('.git'),
            filetypes = { 'php' },
        },
    }
end
lspconfig.php_ls.setup {}

mason_lspconfig.setup_handlers {
    function(server_name)
        require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
        }
    end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}
cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
}



vim.api.nvim_create_user_command('StartMyLsp', function(_)
    -- local capabilities = vim.lsp.protocol.make_client_capabilities()
    vim.lsp.start_client({
        name = 'php-ls',
        filetypes = { 'php' },
        cmd = { '/home/eksandral/projects/php-ls/target/debug/server' },
        root_dir = vim.fs.dirname(vim.fs.find({ 'composer.json', 'index.php' }, { upward = true })[1]),
        capabilities = capabilities,
        settings = {},
        on_attach = on_attach,
        autostart = true,
    })
end, { desc = 'Start custom Lang Server' })
vim.api.nvim_create_user_command('StopAllLsp', function(_)
    vim.lsp.stop_client(vim.lsp.get_clients())
end, { desc = 'Stop All servers' })


--   require("php-ls").setup({
--
--       root_dir = vim.fs.dirname(vim.fs.find({ 'composer.json', 'index.php' }, { upward = true })[1]),
--       capabilities = capabilities,
--   })
