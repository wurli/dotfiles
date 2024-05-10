# dotfiles
Config I use

## Installation on Mac

Just use symlinks, e.g. for `tmux.conf`:
``` bash
ln -s Repos/dotfiles/.tmux.conf .tmux.conf
```

## Installation on Windows 

I.e. at work where _actual_ symlinks aren't allowed without admin permissions
for some reason??

``` powershell
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
