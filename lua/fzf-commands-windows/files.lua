local utils = require "fzf-commands-windows.utils"
local term = require "fzf-commands-windows.term"
local fn, api = utils.helpers()

return function(opts)

  opts = utils.normalize_opts(opts)

  local extra = ''
  if opts.extra then
    extra = fn.join(opts.extra, ' ')
  end

  local command
  if fn.executable("fd") == 1 then
    command = 'fd ' .. extra ..  ' --no-require-git --color never -tf -L --strip-cwd-prefix'
  end

  local preview
  if fn.executable("bat") == 1 then
    preview = vim.env.FZF_PREVIEW_COMMAND .. ' {}'
  else
    preview = 'type "$0"'
  end

  coroutine.wrap(function ()
    local choices = opts.fzf(command,
      (term.fzf_colors .. '--expect=ctrl-s,ctrl-t,ctrl-v,ctrl-r --prompt="Files> " --multi --preview=%s'):format(fn.shellescape(preview)))

    if not choices then return end

    local vimcmd
    if choices[1] == "ctrl-t" then
      vimcmd = "tabnew"
    elseif choices[1] == "ctrl-v" then
      vimcmd = "botright vs"
    elseif choices[1] == "ctrl-s" then
      vimcmd = "new"
    elseif choices[1] == "ctrl-r" then
      vimcmd = "r"
    else
      vimcmd = "e"
    end

    for i=2, #choices do
      vim.cmd(vimcmd .. " " .. fn.fnameescape(choices[i]))
    end

  end)()
end

