dotfiles

========

settings for linux

ln -s dotfiles/.bashrc ~/.bashrc

ln -s dotfiles/.bash_profile ~/.bash_profile

ln -s dotfiles/.gitconfig ~/.gitconfig

ln -s dotfiles/.vimrc ~/.vimrc

ln -s dotfiles/.inputrc ~/.inputrc

ln -s dotfiles/.screenrc ~/.screenrc

ln -s dotfiles/.agignore ~/.agignore

ln -s dotfiles/.agignore ~/.rgignore

mkdir -p ~/.vim/bundle

git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
