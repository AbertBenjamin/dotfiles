-- Migrated from ~/.config/tmux/tmux.conf (prefix ctrl+space)

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
rex.bind("ctrl+space>k", "pane.focus", { direction = "up" })
rex.bind("ctrl+space>l", "pane.focus", { direction = "right" })

-- Vim-aware pane focus (like vim-tmux-navigator): when (n)vim is in the
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

-- Sessionizer in a floating pane (like tmux display-popup). The script writes
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
          command = { os.getenv("HOME") .. "/dotfiles/rex/.config/rex/scripts/rex-sessionizer", "--output", out },
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
