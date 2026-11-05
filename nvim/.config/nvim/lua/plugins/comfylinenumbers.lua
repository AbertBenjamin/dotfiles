vim.pack.add({
  "https://github.com/mluders/comfy-line-numbers.nvim",
})

require('comfy-line-numbers').setup({
  labels = {
    '1', '2', '3', '4', '5', '11', '12', '13', '14', '15', '21', '22', '23',
    '24', '25', '31', '32', '33', '34', '35', '41', '42', '43', '44', '45',
    '51', '52', '53', '54', '55', '111', '112', '113', '114', '115', '121',
    '122', '123', '124', '125', '131', '132', '133', '134', '135', '141',
    '142', '143', '144', '145', '151', '152', '153', '154', '155', '211',
    '212', '213', '214', '215', '221', '222', '223', '224', '225', '231',
    '232', '233', '234', '235', '241', '242', '243', '244', '245', '251',
    '252', '253', '254', '255',
  },
  up_key = 'k',
  down_key = 'j',
  hidden_file_types = { 'undotree' },
  hidden_buffer_types = { 'terminal' },
})

-- comfy-line-numbers sets statuscolumn on every window; keep it off where
-- numbers are disabled (e.g. diffbandit panes)
local function clear_numberless_statuscolumn()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if not vim.wo[win].number and not vim.wo[win].relativenumber then
      vim.wo[win].statuscolumn = ""
    end
  end
end

vim.api.nvim_create_autocmd(
  { "WinNew", "BufWinEnter", "BufEnter", "TermOpen", "InsertEnter", "InsertLeave", "FileType" },
  { callback = clear_numberless_statuscolumn }
)
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = { "number", "relativenumber" },
  callback = clear_numberless_statuscolumn,
})
