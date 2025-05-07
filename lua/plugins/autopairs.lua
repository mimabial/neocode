-- lua/plugins/autopairs.lua
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts = true,
    ts_config = {
      lua = { "string", "source" },
      javascript = { "string", "template_string" },
      typescript = { "string", "template_string" },
      go = { "string" },
    },
    disable_filetype = { "TelescopePrompt", "vim" },
    fast_wrap = {
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = [=[[%'%"%)%>%]%)%}%,]]=],
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "Search",
      highlight_grey = "Comment",
    },
  },
  config = function(_, opts)
    local npairs = require("nvim-autopairs")
    npairs.setup(opts)

    -- Integration with nvim-cmp if available
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    local cmp_ok, cmp = pcall(require, "cmp")
    if cmp_ok then
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end

    -- Enable better treesitter integration if available
    local ts_ok, _ = pcall(require, "nvim-treesitter.configs")
    if ts_ok then
      local Rule = require("nvim-autopairs.rule")
      local ts_conds = require("nvim-autopairs.ts-conds")

      -- Add spaces between parentheses
      npairs.add_rules({
        Rule(" ", " "):with_pair(function(opts)
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({ "()", "[]", "{}" }, pair)
        end):with_move(ts_conds.is_not_ts_node),
        Rule("( ", " )")
          :with_pair(function()
            return false
          end)
          :with_move(function(opts)
            return ts_conds.is_not_ts_node(opts)
          end)
          :use_key(")"),
        Rule("{ ", " }")
          :with_pair(function()
            return false
          end)
          :with_move(function(opts)
            return ts_conds.is_not_ts_node(opts)
          end)
          :use_key("}"),
        Rule("[ ", " ]")
          :with_pair(function()
            return false
          end)
          :with_move(function(opts)
            return ts_conds.is_not_ts_node(opts)
          end)
          :use_key("]"),
      })
    end
  end,
}
