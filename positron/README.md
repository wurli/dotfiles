## Installation

Annoyingly, VSCode/Positron stores configuration in `$HOME/Library/Application\ Support/Code/User/settings.json`. See
<https://code.visualstudio.com/docs/getstarted/settings#_settings-file-locations> for more info.

This means these config files need some manual installation.

``` bash
ln ~/Repos/dotfiles/positron/keybindings.json ~/Repos/dotfiles/positron/keybindings.json .
```

Btw because I always forget, you also need to do this for the VSCode Neovim plugin:

For Positron (Mac):
``` bash
defaults write com.rstudio.positron ApplePressAndHoldEnabled -bool false
```

For VSCode (on Mac):
``` bash
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
```
