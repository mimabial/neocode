-- Plugin spec for Oil.nvim explorer
return {
  "stevearc/oil.nvim",
  lazy = false,
  priority = 900, -- Increased priority to load before other UI components
  dependencies = { { "nvim-tree/nvim-web-devicons", lazy = true } },

  opts = {
    default_file_explorer = true,
    use_default_keymaps = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    auto_refresh = true,

    columns = { "icon", "size", "mtime" },

    buf_options = {
      buflisted = false,
      bufhidden = "hide",
    },
    win_options = {
      wrap = false,
      signcolumn = "no",
      cursorcolumn = false,
      foldcolumn = "0",
      spell = false,
      list = false,
      conceallevel = 3,
      concealcursor = "nvic",
    },

    keymaps = vim.tbl_extend("force", {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
      ["K"] = "actions.preview",
      ["<C-s>"] = "actions.select_vsplit",
      ["<C-h>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
    }, {
      yp = {
        callback = function()
          local oil = require("oil")
          local entry = oil.get_cursor_entry()
          if entry then
            local path = oil.get_current_dir() .. entry.name
            vim.fn.setreg("+", path)
            vim.notify("Copied path: " .. path, vim.log.levels.INFO)
          end
        end,
        desc = "Copy file path",
      },
      yn = {
        callback = function()
          local oil = require("oil")
          local entry = oil.get_cursor_entry()
          if entry then
            vim.fn.setreg("+", entry.name)
            vim.notify("Copied name: " .. entry.name, vim.log.levels.INFO)
          end
        end,
        desc = "Copy file name",
      },
      ["n"] = {
        callback = function()
          vim.ui.input({ prompt = "New file: " }, function(name)
            if name and name ~= "" then
              local oil = require("oil")
              local path = oil.get_current_dir() .. name
              vim.fn.writefile({}, path)
              oil.refresh()
            end
          end)
        end,
        desc = "Create new file",
      },
      ["N"] = {
        callback = function()
          vim.ui.input({ prompt = "New directory: " }, function(name)
            if name and name ~= "" then
              local oil = require("oil")
              local path = oil.get_current_dir() .. name
              vim.fn.mkdir(path, "p")
              oil.refresh()
            end
          end)
        end,
        desc = "Create new directory",
      },
    }),

    view_options = {
      show_hidden = true,
      is_hidden_file = function(name)
        local base = vim.startswith(name, ".")
          or name == "node_modules"
          or name == "vendor"
          or name == "dist"
          or name == ".next"
          or name == "build"
        local stack = vim.g.current_stack
        if stack == "goth" then
          base = base or name == "go.sum" or name == "bin"
        elseif stack == "nextjs" then
          base = base or name == ".turbo" or name == ".vercel" or name == "out"
        end
        return base
      end,
      is_always_hidden = function(name)
        return name == ".git" or name == ".DS_Store"
      end,
    },

    float = {
      padding = 2,
      max_width = 0.9,
      max_height = 0.9,
      border = "rounded",
      win_options = { winblend = 0 },
      override = function(conf) return conf end,
    },

    preview = {
      border = "rounded",
      win_options = { winblend = 0 },
      max_width = 0.9,
      min_width = { 40, 0.4 },
      max_height = 0.9,
      min_height = { 5, 0.1 },
    },

    progress = {
      border = "rounded",
      win_options = { winblend = 0 },
      max_width = 0.9,
      min_width = { 40, 0.4 },
      max_height = { 10, 0.9 },
      min_height = { 5, 0.1 },
    },
  },

  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    { "_", "<CMD>Oil .<CR>", desc = "Open project root" },
    { "<leader>o", "<CMD>Oil --float<CR>", desc = "Open parent (float)" },
    { "<leader>O", "<CMD>Oil .<CR>", desc = "Open root" },
    { "<leader>e", "<CMD>Oil<CR>", desc = "Oil Explorer" },
    { "<leader>E", "<CMD>Oil --float<CR>", desc = "Oil Explorer (float)" },
  },

  config = function(_, opts)
    local oil = require("oil")
    oil.setup(opts)

    vim.api.nvim_create_user_command("OilGOTH", function()
      vim.g.current_stack = "goth"
      oil.open()
      vim.notify("Oil focused on GOTH stack", vim.log.levels.INFO)
    end, { desc = "Oil explorer: GOTH stack" })

    vim.api.nvim_create_user_command("OilNextJS", function()
      vim.g.current_stack = "nextjs"
      oil.open()
      vim.notify("Oil focused on Next.js stack", vim.log.levels.INFO)
    end, { desc = "Oil explorer: Next.js stack" })

    -- Gruvbox Material highlights using local function
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        -- Local helper function to safely get highlight colors
        local function get_hl_color(name, attr, default)
          local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name })
          if ok and hl and hl[attr] then
            if type(hl[attr]) == "number" then
              return string.format("#%06x", hl[attr])
            end
            return tostring(hl[attr])
          end
          return default
        end

        local green = get_hl_color("GruvboxGreen", "fg", "#89b482")
        local aqua  = get_hl_color("GruvboxAqua",  "fg", "#7daea3")
        local yellow= get_hl_color("GruvboxYellow","fg", "#d8a657")
        local red = get_hl_color("GruvboxRed", "fg", "#ea6962")
        local purple = get_hl_color("GruvboxPurple", "fg", "#d3869b")

        vim.api.nvim_set_hl(0, "OilDir",    { fg = aqua,  bold = true })
        vim.api.nvim_set_hl(0, "OilLink",   { fg = green, underline = true })
        vim.api.nvim_set_hl(0, "OilFile",   { fg = yellow })
        vim.api.nvim_set_hl(0, "OilCreate", { fg = green, bold = true })
        vim.api.nvim_set_hl(0, "OilDelete", { fg = red, bold = true })
        vim.api.nvim_set_hl(0, "OilMove",   { fg = purple, bold = true })
        vim.api.nvim_set_hl(0, "OilCopy",   { fg = aqua, bold = true })
        vim.api.nvim_set_hl(0, "OilChange", { fg = yellow, bold = true })
      end,
    })

    vim.api.nvim_create_user_command("OilFloat", function()
      oil.open_float()
    end, { desc = "Open Oil float" })

    -- Buffer-local keymaps for oil filetype
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "oil",
      callback = function()
        vim.opt_local.cursorline = true
        local map = function(m, lhs, rhs, desc)
          vim.keymap.set(m, lhs, rhs, { buffer = true, silent = true, desc = desc })
        end
        map("n", "?", "g?", "Show help")
        map("n", "q", "<cmd>close<cr>", "Close Oil") -- Fixed closing command
      end,
    })
  end,
}
