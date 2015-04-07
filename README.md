dotfiles

========

settings for linux

ln -s dotfiles/.bashrc ~/.bashrc

ln -s dotfiles/.gitconfig ~/.gitconfig

ln -s dotfiles/.vimrc ~/.vimrc

ln -s dotfiles/.inputrc ~/.inputrc

ln -s dotfiles/.screenrc ~/.screenrc

mkdir -p ~/.vim/bundle

git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
