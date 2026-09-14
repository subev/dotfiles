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
  --   <leader>tS  speak Claude's last summary (see config/claude_speak.lua)
  --   <leader>tq / <leader>tc / <leader>tn / <leader>tN  queue add/clear/next/prev
  --
  -- Backed by the local Kokoro server that the com.petur.kokoro-tts LaunchAgent
  -- keeps running on 8741, the same one Spotter uses. `:TTSBackend macos` falls
  -- back to `say` when that server is down; `curl 127.0.0.1:8741/voices` lists
  -- what Kokoro has, since :TTSVoices reports OpenAI names this server lacks.
  {
    "subev/tts.nvim", -- fork; adds player_args (chriswritescode-dev/tts.nvim#3) the rate below needs
    -- Pinned to the PR branch, because the fix is not on the fork's main until
    -- that merges. Without it a fresh machine installs main and plays at 1.0x.
    branch = "feat/playback-player-args",
    opts = {
      backend = "openai",
      openai = {
        -- The server only ever answers WAV, and the plugin names its temp file
        -- after this value, so anything else hands afplay a mislabelled file.
        api_url = "http://127.0.0.1:8741/v1/audio/speech",
        format = "wav",
        voice = "af_heart",
        -- Left natural so the voice keeps the pitch Kokoro generated: raising
        -- this divides the model's predicted durations, which measured ~4%
        -- sharp at 1.5. The speed-up happens at playback instead, below.
        speed = 1.0,
        -- Kokoro is roughly 0.4x realtime, so a long message would otherwise
        -- blow past the 30s default mid-request.
        timeout = 120,
      },
      macos = {
        -- pre-quoted: the plugin concatenates this unescaped into `sh -c "say -v ..."`
        voice = "'Evan (Enhanced)'",
        rate = 260,
      },
      playback = {
        -- The default "line" mode returns before the chunking step, so a long
        -- summary would go out as one huge blocking request -- tens of seconds
        -- of silence before the first word.
        segmentation = "sentence",
        -- A ceiling on how long an uncut sentence may be, not a target size:
        -- only sentences longer than this are split. At 150 a sentence ending
        -- "...so they are all in one place" was cut after "so", and since each
        -- segment is synthesized as its own utterance, Kokoro gave the fragment
        -- final-falling intonation and a trailing pause -- an audible full stop
        -- mid-clause. Normal sentences are never chunked at all, so raising this
        -- costs nothing for them; only a genuinely enormous sentence pays.
        chunk_size = 500,
        -- afplay's rate-scaled playback: a spectral stretch at -q 1 (the default
        -- -q 0 is the cheaper time-domain one), so natural-pace audio plays 1.5x
        -- faster at the same pitch. Needs the fork above, which is where
        -- player_args does something; upstream documents it and never reads it.
        player_args = { "-r", "1.5", "-q", "1" },
      },
      preprocessing = {
        -- Reading fences aloud is noise. This is global, so <leader>tp on a
        -- markdown buffer now skips code too, which is usually what you want.
        skip_code_blocks = true,
      },
    },
  },
}
