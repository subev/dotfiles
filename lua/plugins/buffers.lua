return {
  {
    "jlanzarotta/bufexplorer",
    config = function()
      vim.keymap.set("n", ",B", ":BufExplorerVerticalSplit<CR>", { noremap = true, silent = true })
      vim.g.bufExplorerShowNoName = 1
      vim.g.bufExplorerShowRelativePath = 1
    end,
  },
}
