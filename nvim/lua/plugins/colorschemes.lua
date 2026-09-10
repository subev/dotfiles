return {
  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1000,
    -- init runs before the plugin loads, which is where the style must be set.
    init = function()
      vim.g.sonokai_style = "shusia"
    end,
    config = function()
      vim.cmd.colorscheme("sonokai")
    end,
  },
  { "sainnhe/everforest" },
}
