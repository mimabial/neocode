!#

# go into the plugin folder
cd ~/.local/share/nvim/lazy/bracey.vim

# discard that one file
git restore server/package-lock.json

# (or to wipe *all* local changes:)
git reset --hard
git clean -fd

# now go back to Neovim and update
nvim +'Lazy update bracey.vim' +qall
