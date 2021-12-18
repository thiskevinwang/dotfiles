#!/usr/bin/env bash
#
# This installation is destructive, as it removes exisitng files/directories.
# Use at your own risk.

# Install Powerline fonts
git clone https://github.com/powerline/fonts.git --depth=1
pushd fonts
./install.sh
popd
rm -rf fonts

# Install Oh My Zsh
ZSH_CUSTOM_DIR=${ZSH_CUSTOM:-~/.oh-my-zsh/custom/}/plugins/zsh-autosuggestions
ZSH_AUTOSUGGESTIONS=https://github.com/zsh-users/zsh-autosuggestions

if [[ -d $ZSH_CUSTOM_DIR ]]
then
  echo "Looks like Oh My Zsh is already installed"
else
  echo "Cloning $ZSH_AUTOSUGGESTIONS"
  git clone $ZSH_AUTOSUGGESTIONS $ZSH_CUSTOM_DIR
fi

# Get path to the current script
SCRIPT_NAME="$(basename ${BASH_SOURCE[0]})"
pushd $(dirname ${BASH_SOURCE[0]}) > /dev/null
SCRIPT_DIR=$(pwd)
popd > /dev/null

# names in this list won't be dot-prefixed
skip_dot_prefix=(nvim)

# contains checks if an array ($2) contains a given element ($1).
contains() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# copy or symlink all the dotfiles
UNAME=$(uname | tr '[:upper:]' '[:lower:]')
for path in $SCRIPT_DIR/*; do
  name=$(basename $path)
  case $name in
    *.md|*.sh) continue;;
  esac

  # If there exists a platform-specific version, then use that
  if [ -e "${path}.${UNAME}" ]; then
    echo "Using platform-specific ${name} for ${UNAME}"
    path="${path}.${UNAME}"
  fi

  # If the file is in the skip dot list, then we don't add a dot
  target="$name"
  if ! contains "$name" "${skip_dot_prefix[@]}"; then
    target=".$name"
  fi

  # Build our complete path to the home directory
  target="$HOME/$target"
  if [ -h $target -o -f $target ]; then
    rm $target
  elif [ -d $target ]; then
    rm -rf $target
  fi

  case $UNAME in
    cygwin* | mingw32*)
      cp -R $path "$target"
      echo "Copied $name to $target."
      ;;
    *)
      ln -s $path "$target"
      echo "Linked $name to $target."
      ;;
  esac
done

# setup the vim directory
pushd $HOME >/dev/null
if [ ! -d ".vim/bundle" ]; then
    echo "Installing Vim plugins"
    mkdir -p .vim .vim/bundle .vim/backup .vim/swap .vim/cache .vim/undo
    curl -fLo .vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    TERM=dumb vim +PlugInstall +qall >vim.log 2>&1
fi
popd >/dev/null
echo ""


# VScode extentions
echo "Do you want to install VSCode extentions now?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "\tOk...";
        sh ./.vscode/install-extensions.sh
        break;;
        No ) echo "\tSkipping..."; 
        break;;
    esac
done
echo ""

# Brew
echo "Do you want to run 'brew bundle' now?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "\tOk...";
        brew bundle
        break;;
        No ) echo "\tSkipping..."; 
        break;;
    esac
done
echo ""

