-- Rex keybindings (prefix ctrl+space)

local terminal = "com.superlogical.terminal"

-- Send ctrl+space through to programs that use it themselves
rex.bind("ctrl+space>ctrl+space", "pane.send_key", { key = "ctrl+space" })

rex.bind("ctrl+space>r", "client.config.reload")
rex.bind("ctrl+space>x", "pane.close")
rex.bind("ctrl+space>shift+5", "pane.split", { direction = "right" })
rex.bind("ctrl+space>o", "session.previous")
rex.bind("ctrl+space>i", "session.next")
rex.bind("ctrl+space>h", "pane.focus", { direction = "left" })
rex.bind("ctrl+space>j", "pane.focus", { direction = "down" })
rex.bind("ctrl+space>l", "pane.focus", { direction = "right" })

-- hjkl instead of the arrow keys in Rex's default pane shortcuts
local hjkl = { left = "h", down = "j", up = "k", right = "l" }
for direction, key in pairs(hjkl) do
  rex.unbind("shift+cmd+" .. direction)
  rex.unbind("alt+cmd+" .. direction)
  rex.unbind("alt+shift+cmd+" .. direction)
  rex.bind("shift+cmd+" .. key, "pane.split", { direction = direction })
  rex.bind("alt+cmd+" .. key, "pane.focus", { direction = direction })
  rex.bind("alt+shift+cmd+" .. key, "pane.move", { direction = direction })
end

-- Jump between shell prompts (cmd+k is the session switcher)
rex.unbind("cmd+up")
rex.unbind("cmd+down")
rex.bind("ctrl+cmd+k", "client.prompt.previous")
rex.bind("ctrl+cmd+j", "client.prompt.next")

-- Vim-aware pane focus: when (n)vim is in the
-- foreground the key goes to it, and nvim hands focus back to Rex at its edge
-- via `rex api call session.focus_direction`
local vim_keys = { -- ctrl+h/j/k/l as CSI u, which nvim always understands
  left = "\27[104;5u",
  down = "\27[106;5u",
  up = "\27[107;5u",
  right = "\27[108;5u",
}

rex.action {
  name = "smart_focus",
  title = "Focus Pane (Vim-Aware)",
  args = { direction = "string" },
  run = function(ctx, args)
    local proc = ctx.block_id and rex.block.call(terminal, "process", { block_id = ctx.block_id })
    local fg = proc and proc.foreground and proc.foreground.name or ""
    if fg:match("^g?n?vim?x?$") then
      rex.block.call(terminal, "write", { block_id = ctx.block_id, data = vim_keys[args.direction] })
    else
      rex.call("session.focus_direction", {
        session_id = ctx.session_id,
        direction = args.direction,
        wrap = false,
      })
    end
  end,
}

rex.bind("ctrl+h", "smart_focus", { direction = "left" })
rex.bind("ctrl+j", "smart_focus", { direction = "down" })
rex.bind("ctrl+k", "smart_focus", { direction = "up" })
rex.bind("ctrl+l", "smart_focus", { direction = "right" })

-- Database UI (vim-dadbod-ui) in a floating pane. Runs through an interactive
-- zsh so DB_UI_* / DATABASE_URL from the shell config are available.
rex.bind("ctrl+space>d", function(ctx)
  rex.call("session.new_layer", {
    session_id = ctx.session_id,
    bounds = { 0.05, 0.05, 0.9, 0.9 },
    focus = true,
    layout = {
      block = {
        flavor = "com.superlogical.terminal.shell",
        label = "dbui",
        options = { command = { "zsh", "-ic", "nvim +DBUI" } },
      },
    },
  })
  return true
end)

-- Copy mode à la tmux: the pane's screen and scrollback opened read-only in
-- nvim in a floating pane. Yanks go to the system clipboard (unnamedplus).
rex.bind("ctrl+space>k", function(ctx)
  if not ctx.block_id then return false end
  local cmd = "rex capture -b " .. ctx.block_id .. " --trim --unwrap"
    .. " | nvim -R -c 'setlocal buftype=nofile nomodified' -c 'nnoremap <buffer> q <cmd>q!<cr>' -c 'normal! G' -"
  rex.call("session.new_layer", {
    session_id = ctx.session_id,
    bounds = { 0.05, 0.05, 0.9, 0.9 },
    focus = true,
    layout = {
      block = {
        flavor = "com.superlogical.terminal.shell",
        label = "copy-mode",
        options = { command = { "zsh", "-ic", cmd } },
      },
    },
  })
  return true
end)

-- Sessionizer in a floating pane. The script writes
-- the chosen session id to a file; once the popup closes we switch to it here,
-- since client actions queued from a key binding don't need Remote Control.
rex.bind("ctrl+space>f", function(ctx)
  local out = os.tmpname()
  local r = rex.call("session.new_layer", {
    session_id = ctx.session_id,
    bounds = { 0.1, 0.1, 0.8, 0.8 },
    focus = true,
    layout = {
      block = {
        flavor = "com.superlogical.terminal.shell",
        label = "sessionizer",
        options = {
          command = { os.getenv("HOME") .. "/.config/rex/scripts/rex-sessionizer", "--output", out },
        },
      },
    },
  })
  rex.wait("block_closed", { block_id = r.block_ids[1] }, 600)

  local f = io.open(out)
  local session_id = f and f:read("*l")
  if f then f:close() end
  os.remove(out)

  if session_id and session_id ~= "" then
    rex.client.queue("session.select", { session_id = session_id })
  end
  return true
end)
