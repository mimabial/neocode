-- Go snippets for GOTH stack
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local snippets = {
  -- HTTP Handler
  s("handler", {
    t({"func "}), i(1, "HandlerName"), t({" (w http.ResponseWriter, r *http.Request) {", "\t"}),
    i(0, "// Implementation"),
    t({"", "}"})
  }),
  
  -- Error handling
  s("iferr", {
    t({"if err != nil {", "\t"}),
    i(1, "return err"),
    t({"", "}"})
  }),
  
  -- Templ component handler
  s("templhandler", {
    t({"func "}), i(1, "HandlerName"), t({" (w http.ResponseWriter, r *http.Request) {", "\t"}),
    t({"// Call templ component", "\tcomponents."}), i(2, "Component"), t({"("}), i(3, ""), t({").Render(r.Context(), w)"}),
    t({"", "}"})
  }),
  
  -- Main function for GOTH app
  s("gothmain", {
    t({"package main", "", "import (", "\t\"log\"", "\t\"net/http\"", "", "\t\""}), 
    i(1, "github.com/username/project"), t({"/components\"", "\t\""}),
    f(function(args) return args[1][1] end, {1}), t({"/handlers\"", ")", "", "func main() {", "\t// Setup routes", "\tmux := http.NewServeMux()", "\t"}),
    i(2, "mux.HandleFunc(\"/\", handlers.Index)"),
    t({"\t", "\t// Serve static files", "\tfs := http.FileServer(http.Dir(\"static\"))", "\tmux.Handle(\"/static/\", http.StripPrefix(\"/static/\", fs))", "\t", "\t// Start server", "\tlog.Println(\"Server starting on :"}), i(3, "3000"), t({"...\")", "\tif err := http.ListenAndServe(\":"}), 
    f(function(args) return args[1][1] end, {3}), t({"\", mux); err != nil {", "\t\tlog.Fatal(err)", "\t}", "}"})
  }),
}

return snippets
