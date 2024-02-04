-- TODO: Once the bug (in Neovim or Lualine) which causes Lualine to 
-- remove the default splashscreen is fixed, this plugin can be removed
return {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('alpha').setup(
          require('alpha.themes.startify').config
        )
    end
}

