return {
  'mfussenegger/nvim-jdtls',
  dependencies = {
    'williamboman/mason.nvim',
    'saghen/blink.cmp',
    'mfussenegger/nvim-dap',
  },
  ft = { 'java' },
  opts = function()
    local client_capabilities = vim.lsp.protocol.make_client_capabilities()
    local capabilities = require('blink.cmp').get_lsp_capabilities(client_capabilities)
    local config = {
      capabilities = capabilities,
      cmd = {
        -- 💀
        'java', -- or '/path/to/java17_or_newer/bin/java'
        -- depends on if `java` is in your $PATH env variable and if it points to the right version.

        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',
        '-javaagent:' .. require('mason-registry').get_package('jdtls'):get_install_path() .. '/lombok.jar',

        -- 💀
        '-jar',
        require('mason-registry').get_package('jdtls'):get_install_path() .. '/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar',
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
        -- Must point to the                                                     Change this to
        -- eclipse.jdt.ls installation                                           the actual version

        -- 💀
        '-configuration',
        require('mason-registry').get_package('jdtls'):get_install_path() .. '/config_linux',
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
        -- Must point to the                      Change to one of `linux`, `win` or `mac`
        -- eclipse.jdt.ls installation            Depending on your system.

        -- 💀
        -- See `data directory configuration` section in the README
        '-data',
        vim.fn.expandcmd('~/.workspaces/' .. vim.fn.fnamemodify(vim.fs.root(0, { '.git', 'mvnw', 'gradlew' }) or vim.fn.getcwd(), ':p:h:t')),
      },
      -- 💀
      -- This is the default if not provided, you can remove it. Or adjust as needed.
      -- One dedicated LSP server & client will be started per unique root_dir
      --
      -- vim.fs.root requires Neovim 0.10.
      -- If you're using an earlier version, use: require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),
      root_dir = vim.fs.root(0, { '.git', 'mvnw', 'gradlew' }),

      -- Here you can configure eclipse.jdt.ls specific settings
      -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
      -- for a list of options
      settings = {
        java = {},
      },

      -- Language server `initializationOptions`
      -- You need to extend the `bundles` with paths to jar files
      -- if you want to use additional eclipse.jdt.ls plugins.
      --
      -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
      --
      -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
      init_options = {
        extendedClientCapabilities = require('jdtls').extendedClientCapabilities,
        bundles = vim.list_extend(
          vim.fn.glob(
            require('mason-registry').get_package('java-debug-adapter'):get_install_path() .. '/extension/server/com.microsoft.java.debug.plugin-*.jar',
            false,
            true
          ),
          vim.fn.glob(require('mason-registry').get_package('java-test'):get_install_path() .. '/extension/server/*.jar', false, true)
        ),
      },
    }
    return config
  end,
  config = function(_, opts)
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'java' },
      callback = function()
        require('jdtls').start_or_attach(opts)
      end,
    })

    require('jdtls').start_or_attach(opts)
  end,
}
