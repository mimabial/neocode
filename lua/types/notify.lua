---@meta notify

-- Type stub for rcarriga/nvim-notify. Adds the __call overload that the
-- plugin installs at runtime via setmetatable() but which lua_ls can't see.
-- All methods and option classes are already declared upstream.

---@class notify
---@overload fun(message: string|string[], level?: string|number, opts?: notify.Options): integer
