local M = {}

function M.setup()
  local opt = vim.opt
  local fn = vim.fn

  -- Basic UI
  opt.number = true
  opt.relativenumber = true
  opt.numberwidth = 4
  opt.cursorline = true
  opt.termguicolors = true
  opt.background = "dark"
  opt.signcolumn = "yes:1"
  opt.showtabline = 2
  opt.laststatus = 3
  opt.runtimepath:remove("/usr/share/vim/vimfiles")

  -- Scrolling
  opt.scrolloff = 4
  opt.sidescrolloff = 8

  -- Wrapping
  opt.wrap = false
  opt.linebreak = true
  opt.whichwrap = "bs<>[]hl"

  -- Command line
  opt.cmdheight = 1
  opt.showmode = false
  opt.showcmd = false
  opt.shortmess:append("c")

  -- Indentation
  opt.expandtab = true
  opt.shiftwidth = 2
  opt.tabstop = 2
  opt.softtabstop = 2
  opt.autoindent = true
  opt.smartindent = true
  opt.breakindent = true

  -- Search
  opt.ignorecase = true
  opt.smartcase = true
  opt.hlsearch = true
  opt.incsearch = true

  opt.winbar = ""

  opt.updatetime = 250
  opt.timeoutlen = 300

  -- Backup/swap/undo live under stdpath("state") so lua_ls (which scans
  -- stdpath("data") via the rtp library) doesn't index *.lua~ backup files
  -- and double-count @alias / @class annotations.
  opt.backup = true
  opt.writebackup = true
  opt.backupdir = fn.stdpath("state") .. "/backup//"
  opt.swapfile = true
  opt.directory = fn.stdpath("state") .. "/swap//"
  opt.fsync = false
  opt.undofile = true
  opt.undodir = fn.stdpath("state") .. "/undo//"
  opt.undolevels = 1000
  opt.undoreload = 10000

  for _, dir in ipairs({ "backup", "swap", "undo" }) do
    local path = fn.stdpath("state") .. "/" .. dir
    if fn.isdirectory(path) == 0 then
      fn.mkdir(path, "p")
    end
  end

  -- ShaDa: !=cmd history, '100=marks/file, <50=register lines, s10=item KB cap, h=no hlsearch persist.
  opt.shada = [[!,'100,<50,s10,h]]

  opt.backupskip = { "/tmp/*", "/private/*" }
  opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" }
  opt.confirm = true

  opt.splitright = true
  opt.splitbelow = true

  opt.completeopt = { "menu", "menuone", "noselect" }

  opt.list = true
  opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

  opt.clipboard = "unnamedplus"

  opt.foldlevel = 99
  opt.foldlevelstart = 99
  opt.foldenable = true
  opt.fillchars = { eob = " " }

  -- Listen server so external tools (theme sync) can send commands.
  if not vim.g.started_server and vim.fn.serverlist()[1] == nil then
    local runtime_dir = vim.env.XDG_RUNTIME_DIR or ("/run/user/" .. vim.uv.getuid())
    local socket = runtime_dir .. "/nvim." .. vim.fn.getpid() .. ".0"
    pcall(vim.fn.serverstart, socket)
    vim.g.started_server = true
  end
end

return M
