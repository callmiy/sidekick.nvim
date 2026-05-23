---@module 'luassert'

local Tmux = require("sidekick.cli.session.tmux")
local Util = require("sidekick.util")

describe("tmux codex metadata", function()
  local original_exec
  local original_codex_root

  before_each(function()
    original_exec = Util.exec
    original_codex_root = vim.env.CODEX_ROOT
  end)

  after_each(function()
    Util.exec = original_exec
    vim.env.CODEX_ROOT = original_codex_root
  end)

  it("extracts codex session id from status output", function()
    assert.are.equal(
      "019e4a4e-db89-7e53-a7e7-95edfeb5aa17",
      Tmux._test.codex_session_id({
        "│  Session:                     019e4a4e-db89-7e53-a7e7-95edfeb5aa17                      │",
      })
    )
  end)

  it("extracts codex session id from rollout path", function()
    assert.are.equal(
      "019e5573-f54f-7e50-ad99-e5491082a4c4",
      Tmux._test.codex_session_id_from_path(
        "/home/user/.codex/sessions/2026/05/23/rollout-2026-05-23T11-28-43-019e5573-f54f-7e50-ad99-e5491082a4c4.jsonl"
      )
    )
  end)

  it("ignores non-rollout paths when extracting codex session id", function()
    assert.is_nil(Tmux._test.codex_session_id_from_path("/home/user/.codex/state_5.sqlite"))
  end)

  it("extracts thread name from status output", function()
    assert.are.equal(
      "sidekick.nvim",
      Tmux._test.codex_thread_name({
        "│  Thread name:                 sidekick.nvim                                             │",
      })
    )
  end)

  it("resolves title from codex state database", function()
    local root = vim.fn.tempname()
    vim.fn.mkdir(root, "p")
    vim.fn.writefile({}, root .. "/state_5.sqlite")
    vim.env.CODEX_ROOT = root

    Util.exec = function(cmd)
      assert.are.same("sqlite3", cmd[1])
      assert.are.same("-readonly", cmd[2])
      assert.are.same(root .. "/state_5.sqlite", cmd[3])
      assert.matches("019e4a92%-9f2f%-7b11%-8d39%-37dedd6539fd", cmd[4])
      return { "736964656B69636B0A6E76696D" }
    end

    assert.are.equal("sidekick nvim", Tmux._test.codex_title_from_state("019e4a92-9f2f-7b11-8d39-37dedd6539fd"))
  end)

  it("ignores invalid hex from codex state database", function()
    local root = vim.fn.tempname()
    vim.fn.mkdir(root, "p")
    vim.fn.writefile({}, root .. "/state_5.sqlite")
    vim.env.CODEX_ROOT = root

    Util.exec = function()
      return { "not hex" }
    end

    assert.is_nil(Tmux._test.codex_title_from_state("019e4a92-9f2f-7b11-8d39-37dedd6539fd"))
  end)
end)
