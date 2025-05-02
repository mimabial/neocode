-- Templ snippets for GOTH stack
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local snippets = {
  -- Basic component
  s("component", {
    t({"package components", "", "type "}), i(1, "Component"), t({"Props struct {", "\t"}),
    i(2, "// Props"),
    t({"", "}", "", "templ "}), f(function(args) return args[1][1] end, {1}), t({" (props "}), f(function(args) return args[1][1] end, {1}), t({"Props) {", "\t"}),
    i(0, "<div>Component content</div>"),
    t({"", "}"})
  }),
  
  -- Layout component
  s("layout", {
    t({"package components", "", "type LayoutProps struct {", "\tTitle string", "\tContent templ.Component", "}", "", "templ Layout(props LayoutProps) {", "\t<!DOCTYPE html>", "\t<html lang=\"en\">", "\t\t<head>", "\t\t\t<meta charset=\"UTF-8\"/>", "\t\t\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"/>", "\t\t\t<title>{ props.Title }</title>", "\t\t\t<script src=\"https://unpkg.com/htmx.org@1.9.4\"></script>", "\t\t\t<script src=\"https://cdn.tailwindcss.com\"></script>", "\t\t</head>", "\t\t<body class=\"bg-gray-100 min-h-screen\">", "\t\t\t<main class=\"container mx-auto p-4\">", "\t\t\t\t{ props.Content }", "\t\t\t</main>", "\t\t</body>", "\t</html>", "}"})
  }),

  -- HTMX snippets
  s("hx-get", {
    t("hx-get=\""), i(1, "/path"), t("\"")
  }),
  s("hx-post", {
    t("hx-post=\""), i(1, "/path"), t("\"")
  }),
  s("hx-put", {
    t("hx-put=\""), i(1, "/path"), t("\"")
  }),
  s("hx-delete", {
    t("hx-delete=\""), i(1, "/path"), t("\"")
  }),
  s("hx-patch", {
    t("hx-patch=\""), i(1, "/path"), t("\"")
  }),
  s("hx-trigger", {
    t("hx-trigger=\""), i(1, "event"), t("\"")
  }),
  s("hx-swap", {
    t("hx-swap=\""), i(1, "innerHTML"), t("\"")
  }),
  s("hx-target", {
    t("hx-target=\""), i(1, "#id"), t("\"")
  }),
  s("hx-boost", {
    t("hx-boost=\""), i(1, "true"), t("\"")
  }),
  
  -- Form snippet with HTMX
  s("form", {
    t({"<form hx-post=\""}), i(1, "/path"), t({"\" hx-swap=\"outerHTML\">", "\t"}),
    i(2, "<input type=\"text\" name=\"name\" />"),
    t({"", "\t<button type=\"submit\" class=\"px-4 py-2 bg-blue-500 text-white rounded\">Submit</button>", "</form>"})
  }),
  
  -- Button with HTMX
  s("button", {
    t({"<button", "\tclass=\"px-4 py-2 bg-blue-500 hover:bg-blue-700 text-white font-bold rounded\"", "\thx-"}), i(1, "post"), t({"=\""}), i(2, "/path"), t({"\"", "\thx-swap=\"outerHTML\"", ">"}),
    i(3, "Button Text"),
    t({"</button>"})
  }),
}

return snippets
