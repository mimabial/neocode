-- TypeScript snippets for Next.js
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local snippets = {
  -- Next.js API route
  s("napi", {
    t({"export async function GET(request: Request) {", "  "}),
    i(1, "// Handle GET request"),
    t({"", "  return Response.json({ message: 'Hello from API route!' });", "}", ""}),
  }),
  
  -- Next.js API handler with multiple HTTP methods
  s("napi-methods", {
    t({"export async function GET(request: Request) {", "  "}),
    i(1, "// Handle GET request"),
    t({"", "  return Response.json({ message: 'Hello from GET' });", "}", "", "export async function POST(request: Request) {", "  const body = await request.json();", "  ", "  "}),
    i(2, "// Handle POST request"),
    t({"", "  return Response.json({ message: 'Hello from POST', received: body });", "}", ""}),
  }),
  
  -- Next.js dynamic API route
  s("napi-dynamic", {
    t({"export async function GET(", "  request: Request,", "  { params }: { params: Promise<{ "}),
    i(1, "id"),
    t({": string }> }", ") {", "  "}),
    t({"const { "}), f(function(args) return args[1][1] end, {1}), t({" } = await params;", "  ", "  return Response.json({ "}),
    f(function(args) return args[1][1] end, {1}), t({" });", "}", ""}),
  }),
}

return snippets
