---@module 'luassert'

local Select = require("sidekick.cli.ui.select")

describe("cli select formatting", function()
  it("includes session title when present", function()
    local parts = Select.format({
      started = true,
      external = true,
      installed = true,
      tool = { name = "codex" },
      session = {
        backend = "tmux",
        cwd = "/tmp/project",
        mux_session = "dot:2.2",
        title = "dotfiles",
      },
    })

    local text = table.concat(vim.tbl_map(function(part)
      return part[1]
    end, parts))

    assert.matches("%[tmux:dot:2%.2%]", text)
    assert.matches("/tmp/project", text)
    assert.matches("%[dotfiles%]", text)
  end)

  it("omits empty session title", function()
    local parts = Select.format({
      started = true,
      external = true,
      installed = true,
      tool = { name = "codex" },
      session = {
        backend = "tmux",
        cwd = "/tmp/project",
        mux_session = "dot:2.2",
        title = "",
      },
    })

    local text = table.concat(vim.tbl_map(function(part)
      return part[1]
    end, parts))

    assert.not_matches("%[%]", text)
  end)
end)
