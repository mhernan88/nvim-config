return {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        -- LSP Support
        'neovim/nvim-lspconfig',             -- Required
        'williamboman/mason.nvim',           -- Optional
        'williamboman/mason-lspconfig.nvim', -- Optional

        -- Autocompletion
        'hrsh7th/nvim-cmp',     -- Required
        'hrsh7th/cmp-nvim-lsp', -- Required
        'L3MON4D3/LuaSnip',     -- Required
    },
    config = function()
        local lsp_zero = require("lsp-zero").preset("recommended")
        local cmp = require("cmp")
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local lspconfig = require("lspconfig")
        local lsnip = require("luasnip")

        -- Luasnip
        require("luasnip.loaders.from_lua").load()
        lsnip.setup({
            history = true,
            update_events = { "TextChanged", "TextChangedI" },
            enable_autosnippets = true,
        })

        lsp_zero.on_attach(function(_, bufnr)
            lsp_zero.default_keymaps({ buffer = bufnr })
            vim.keymap.set(
            "n",
            "gr",
            "<Cmd>Telescope lsp_references<CR>",
            { buffer = true, desc = "Show references in a Telescope window." }
            )
        end)

        -- Language servers
        lsp_zero.ensure_installed({
            "pyright",
            "rust_analyzer",
            "gopls",
        })
        lspconfig.lua_ls.setup({
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim", "s", "t", "i", "d", "c", "sn", "f" },
                    },
                    format = {
                        enable = false,
                    },
                },
            },
        })
        lspconfig.clangd.setup({
            arguments = { "-Wall" },
        })
        lspconfig.pyright.setup({
            settings = {
                python = {
                    analysis = {
                        diagnosticSeverityOverrides = {
                            reportPropertyTypeMismatch = true,
                            reportImportCycles = "warning",
                            reportUnusedFunction = "warning",
                            reportDuplicateImport = "warning",
                            reportPrivateUsage = "warning",
                            reportTypeCommentUsage = "warning",
                            reportConstantRedefinition = "error",
                            reportDeprecated = "warning",
                            reportIncompatibleMethodOverride = "error",
                            reportIncompatibleVariableOverride = "error",
                            reportInconsistentConstructor = "error",
                            reportOverlappingOverload = "error",
                            reportMissingSuperCall = "error",
                            reportUnititializedInstanceVariable = "error",
                            reportUnknownParameterType = "warning",
                            reportUnknownArgumentType = "warning",
                            reportUnknownLambdaType = "warning",
                            reportUnknownVariableType = "warning",
                            reportUnknownMemberType = "warning",
                            reportMissingParameterType = "error",
                            reportMissingTypeArgument = "warning",
                            reportUnnecessaryIsInstance = "warning",
                            reportUnnecessaryCast = "warning",
                            reportUnnecessaryComparison = "warning",
                            reportUnnecessaryContains = "warning",
                            reportAssertAlwaysTrue = "warning",
                            reportSelfClsParameterName = "error",
                            reportImplicitStringConcatenation = "warning",
                            reportUnusedExpression = "warning",
                            reportUnnecessaryTypeIgnoreComment = "warning",
                            reportMatchNotExhaustive = "error",
                            reportShadowedImports = "error",
                        },
                    },
                },
            },
        })
        lspconfig.rust_analyzer.setup({
            settings = {
                ["rust-analyzer"] = {
                    check = {
                        command = "clippy",
                    },
                },
            },
        })

        -- Completion setup
        cmp.setup({
            sources = {
                { name = "luasnip", option = { show_autosnippets = true } },
                { name = "nvim_lua" },
                { name = "nvim_lsp" },
                { name = "path" },
            },
            mapping = {
                --- @param fallback function
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif lsnip.expand_or_jumpable() then
                        lsnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }), -- Tab autocomplete
                --- @param fallback function
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif lsnip.jumpable(-1) then
                        lsnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Enter to complete
                ["<Up>"] = cmp.mapping.abort(), -- No up and down selection
                ["<Down>"] = cmp.mapping.abort(),
                --- @param fallback function
                ["<C-l>"] = cmp.mapping(function(fallback) -- Move choice forward
                    if lsnip.choice_active() then
                        lsnip.change_choice()
                    else
                        fallback()
                    end
                end),
                --- @param fallback function
                ["<C-h>"] = cmp.mapping(function(fallback) -- Move choice backward
                    if lsnip.choice_active() then
                        lsnip.change_choice(-1)
                    else
                        fallback()
                    end
                end),
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            -- Expands snippets
            snippet = {
                expand = function(args) lsnip.lsp_expand(args.body) end,
            },
        })

        -- Autoclose parenthesis on function completion
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

        lsp_zero.setup()
    end,
}