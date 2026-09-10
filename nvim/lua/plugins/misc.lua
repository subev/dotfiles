return {
  {
    "mbbill/undotree",
    lazy = true,
    keys = {
      { "<leader>u", ":UndotreeToggle<cr>", noremap = true, silent = true, desc = "Toggle Undotree" },
    },
    cmd = { "UndotreeToggle" },
  },
  {
    "mhanberg/output-panel.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("output_panel").setup({
        max_buffer_size = 5000, -- default
      })
    end,
    cmd = { "OutputPanel" },
    keys = {
      {
        "<leader>o",
        vim.cmd.OutputPanel,
        mode = "n",
        desc = "Toggle the output panel",
      },
    },
  },
  { "meznaric/key-analyzer.nvim", opts = {} },
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
    dependencies = {
      -- include a picker of your choice, see picker section for more details
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      arg = "leet",
      lang = "typescript",
    },
    lazy = true,
    cmd = { "Leet" },
  },
  {
    -- does not seem to work
    "MaximilianLloyd/tw-values.nvim",
    keys = {
      { "<leader><space><space>", "<cmd>TWValues<cr>", desc = "Show tailwind CSS values" },
    },
    opts = {
      border = "rounded", -- Valid window border style,
      show_unknown_classes = true, -- Shows the unknown classes popup
      focus_preview = true, -- Sets the preview as the current window
      copy_register = "", -- The register to copy values to,
      keymaps = {
        copy = "<C-y>", -- Normal mode keymap to copy the CSS values between {}
      },
    },
  },
  "chrisbra/csv.vim",
  "junegunn/vim-easy-align",
  -- nice markdown preview
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "markdown", "codecompanion" },
    opts = {
      file_types = { "markdown", "codecompanion" },
      -- keep the cursor line rendered; insert mode already reveals raw text
      anti_conceal = { enabled = false },
    },
  },
  -- Read text aloud (visual selection, paragraph, or motion).
  --
  -- Usage:
  --   <leader>tp  play visual selection (or current section in normal mode)
  --   <leader>ts  stop playback
  --   <leader>tq / <leader>tc / <leader>tn / <leader>tN  queue add/clear/next/prev
  --
  -- Currently on the native macOS `say` backend. To upgrade voice quality later,
  -- run a local Kokoro server (ghcr.io/remsky/kokoro-fastapi-cpu, port 8880) and
  -- switch with :TTSBackend openai after filling in the openai table below.
  {
    "chriswritescode-dev/tts.nvim",
    opts = {
      backend = "macos",
      macos = {
        -- pre-quoted: the plugin concatenates this unescaped into `sh -c "say -v ..."`
        voice = "'Evan (Enhanced)'",
        rate = 260,
      },
    },
  },
}
