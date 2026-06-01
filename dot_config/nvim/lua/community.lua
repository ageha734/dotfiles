-- AstroCommunity imports for AstroNvim v5

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
    "AstroNvim/astrocommunity",
    { import = "astrocommunity.pack.lua" },
    { import = "astrocommunity.pack.rust" },
    { import = "astrocommunity.pack.python" },
    { import = "astrocommunity.pack.typescript" },
    { import = "astrocommunity.pack.json" },
    { import = "astrocommunity.pack.dart" },
    { import = "astrocommunity.quickfix.nvim-bqf" },
    { import = "astrocommunity.utility.mason-tool-installer-nvim" },
    { import = "astrocommunity.fuzzy-finder.telescope-nvim" },
    { import = "astrocommunity.motion.nvim-spider" },
    { import = "astrocommunity.motion.leap-nvim" },
    { import = "astrocommunity.colorscheme.catppuccin" },
    { import = "astrocommunity.split-and-window.mini-map" },
    { import = "astrocommunity.editing-support.dial-nvim" },
    { import = "astrocommunity.markdown-and-latex.vimtex" },
    -- import/override with your plugins folder
}
