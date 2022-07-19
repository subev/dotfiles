#export JAVA_HOME=$(/usr/libexec/java_home)

export CLOUDSDK_PYTHON_SITEPACKAGES=1

export PATH=$HOME/google-cloud-sdk/platform/google_appengine:$PATH

export PATH=$HOME/.stack/programs/x86_64-osx/ghc-8.0.2/bin:$PATH
export PATH=$HOME/.local/bin:$PATH

export RUST_SRC_PATH=${HOME}/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src

source $HOME/.bashrc

if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi

eval $(thefuck --alias)

test -e ${HOME}/.iterm2_shell_integration.bash && source ${HOME}/.iterm2_shell_integration.bash


# The next line updates PATH for the Google Cloud SDK.
if [ -f ${HOME}/google-cloud-sdk/path.bash.inc ]; then . ${HOME}/google-cloud-sdk/path.bash.inc; fi

# The next line enables shell command completion for gcloud.
if [ -f ${HOME}/google-cloud-sdk/completion.bash.inc ]; then . ${HOME}/google-cloud-sdk/completion.bash.inc; fi

. "$HOME/.cargo/env"

. /opt/homebrew/opt/asdf/libexec/asdf.sh

. /opt/homebrew/opt/asdf/etc/bash_completion.d/asdf.bash
