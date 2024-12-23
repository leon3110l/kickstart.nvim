return {
  'saghen/blink.cmp',
  version = 'v0.*',
  dependencies = 'rafamadriz/friendly-snippets',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = 'default' },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
    },
  },
}
