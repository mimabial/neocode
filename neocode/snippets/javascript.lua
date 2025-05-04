-- JavaScript snippets for Next.js
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

local snippets = {
  -- Next.js config
  s("nconfig", {
    t({"/** @type {import('next').NextConfig} */", "const nextConfig = {", "  "}),
    c(1, {
      t({"// Base configuration", "reactStrictMode: true,"}),
      t({"// With redirects", "reactStrictMode: true,", "  async redirects() {", "    return [", "      {", "        source: '/old-path',", "        destination: '/new-path',", "        permanent: true,", "      },", "    ];", "  },"}),
      t({"// With image domains", "reactStrictMode: true,", "  images: {", "    domains: ['example.com'],", "  },"}),
      t({"// With API rewrites", "reactStrictMode: true,", "  async rewrites() {", "    return {", "      beforeFiles: [", "        {", "          source: '/api/:path*',", "          destination: 'https://api.example.com/:path*',", "        },", "      ],", "    };", "  },"}),
    }),
    t({"", "};", "", "module.exports = nextConfig;", ""}),
  }),
}

return snippets
