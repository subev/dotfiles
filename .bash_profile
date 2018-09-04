#export JAVA_HOME=$(/usr/libexec/java_home -v 1.7)

# The next line updates PATH for the Google Cloud SDK.
source '/Users/petur/google-cloud-sdk/path.bash.inc'

# The next line enables bash completion for gcloud.
source '/Users/petur/google-cloud-sdk/completion.bash.inc'

export CLOUDSDK_PYTHON_SITEPACKAGES=1

export PATH=$HOME/work/arcanist/bin:$PATH

export PATH=$HOME/google-cloud-sdk/platform/google_appengine:$PATH

export PATH=$HOME/.stack/programs/x86_64-osx/ghc-8.0.2/bin:$PATH

export RUST_SRC_PATH="/Users/petur/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src"

source $HOME/work/arcanist/resources/shell/bash-completion

source $HOME/.bashrc

if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi

eval $(thefuck --alias)

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

export PATH="$HOME/.cargo/bin:$PATH"
