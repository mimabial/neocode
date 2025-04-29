-- Next.js snippets
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node

local snippets = {
  -- Next.js page component
  s("npage", {
    t({"export default function Page() {", "  return (", "    "}),
    i(1, "<div>Page content</div>"),
    t({"", "  );", "}", ""}),
  }),
  
  -- Next.js layout component
  s("nlayout", {
    t({"export default function Layout({ children }: { children: React.ReactNode }) {", "  return (", "    "}),
    i(1, "<div>{children}</div>"),
    t({"", "  );", "}", ""}),
  }),
  
  -- Next.js server component
  s("nserver", {
    t({"import { headers } from 'next/headers';", "", "export default async function ServerComponent() {", "  const headersList = headers();", "  ", "  return (", "    "}),
    i(1, "<div>Server Component</div>"),
    t({"", "  );", "}", ""}),
  }),
  
  -- Next.js client component
  s("nclient", {
    t({"'use client';", "", "import { useState } from 'react';", "", "export default function ClientComponent() {", "  const [state, setState] = useState("}),
    i(1, "null"),
    t({");", "  ", "  return (", "    "}),
    i(2, "<div>Client Component</div>"),
    t({"", "  );", "}", ""}),
  }),
  
  -- Next.js API route
  s("napi", {
    t({"export async function GET(request: Request) {", "  "}),
    i(1, "// Handle GET request"),
    t({"", "  return Response.json({ message: 'Hello from API route!' });", "}", ""}),
  }),
  
  -- Next.js with route params
  s("nparams", {
    t({"interface PageProps {","  params: {","    "}),
    i(1, "id"),
    t({": string","  }","}","","export default function Page({ params }: PageProps) {","  return (","    <div>","      Dynamic parameter: {params."}),
    f(function(args) return args[1][1] end, {1}),
    t({"}","    </div>","  );","}",""}),
  }),

  
  -- Next.js with search params
  s("nsearch", {
    t({"export default function Page({","  searchParams,","}: {","  searchParams: { [key: string]: string | string[] | undefined };","}) {","  return (","    <div>","      Search param: {searchParams."}),
    i(1, "query"),
    t({" as string}","    </div>","  );","}",""}),
  }),
  
  -- Next.js with data fetching
  s("nfetch", {
    t({"async function getData() {", "  const res = await fetch('"}),
    i(1, "https://api.example.com/data"),
    t("', "),
    c(2, {
      t({"// No cache - revalidate every request", "  { cache: 'no-store' }"}),
      t({"// Cache with revalidation", "  { next: { revalidate: 60 } }"}),
      t({"// Cache until manually revalidated", "  { cache: 'force-cache' }"}),
    }),
    t({");", "  ", "  if (!res.ok) {", "    throw new Error('Failed to fetch data');", "  }", "  ", "  return res.json();", "}", "", "export default async function Page() {", "  const data = await getData();", "  ", "  return (", "    <div>", "      <h1>Data:</h1>", "      <pre>{JSON.stringify(data, null, 2)}</pre>", "    </div>", "  );", "}", ""}),
  }),
  
  -- React useState hook
  s("ust", {
    t({"const ["}),
    i(1, "state"),
    t({", set"}),
    f(function(args)
      local state = args[1][1]
      return state:gsub("^%l", string.upper)
    end, {1}),
    t({"] = useState("}),
    i(2, "initialState"),
    t({");"}),
  }),
  
  -- React useEffect
  s("uef", {
    t({"useEffect(() => {", "  "}),
    i(1, "// Effect code"),
    t({"", "  return () => {", "    "}),
    i(2, "// Cleanup code"),
    t({"", "  };", "}, ["}),
    i(3, "/* dependencies */"),
    t({"]);"}),
  }),
  
  -- React component with props
  s("rcomp", {
    t({"interface "}),
    i(1, "Component"),
    t({"Props {", "  "}),
    i(2, "// Props"),
    t({"", "}", "", "export function "}),
    f(function(args) return args[1][1] end, {1}),
    t({"({ "}),
    i(3, "/* destructured props */"),
    t({" }: "}),
    f(function(args) return args[1][1] end, {1}),
    t({"Props) {", "  return (", "    "}),
    i(0, "<div></div>"),
    t({"", "  );", "}", ""}),
  }),
  
  -- Next.js metadata export
  s("nmeta", {
    t({"export const metadata = {", "  title: '"}),
    i(1, "Page Title"),
    t({"',", "  description: '"}),
    i(2, "Page Description"),
    t({"',", "};", ""}),
  }),
}

return snippets
