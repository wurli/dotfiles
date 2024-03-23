# dotfiles
Configuration settings I use

## Installation on Mac

Just use symlinks, e.g. for `tmux.conf`:
``` zsh
ln -s Repos/dotfiles/.tmux.conf .tmux.conf
```

## Installation on Windows 

```powershell
function symlink ([String] $real, [String] $link) {
    if (Test-Path $real -pathType container) {
        # Create a hardlink for individual files
        cmd /c mklink /j $link.Replace("/", "\") $real.Replace("/", "\")
    } else {
        # Create a junction for folders
        cmd /c mklink /h $link.Replace("/", "\") $real.Replace("/", "\")
    }
}

symlink .bashrc $HOME\~\.bashrc
symlink .gitconfig $HOME\~\.gitconfig
symlink .lintr $HOME\~\.lintr
symlink nvim $HOME\AppData\Local\nvim
```
