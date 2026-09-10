# Login shell config. Interactive setup lives in ~/.bashrc, which this sources.

export CLOUDSDK_PYTHON_SITEPACKAGES=1

export PATH=$HOME/google-cloud-sdk/platform/google_appengine:$PATH
export PATH=$HOME/.local/bin:$PATH

export RUST_SRC_PATH=${HOME}/.rustup/toolchains/stable-aarch64-apple-darwin/lib/rustlib/src/rust/src

source $HOME/.bashrc

test -e ${HOME}/.iterm2_shell_integration.bash && source ${HOME}/.iterm2_shell_integration.bash

# The next line updates PATH for the Google Cloud SDK.
if [ -f ${HOME}/google-cloud-sdk/path.bash.inc ]; then . ${HOME}/google-cloud-sdk/path.bash.inc; fi

# The next line enables shell command completion for gcloud.
if [ -f ${HOME}/google-cloud-sdk/completion.bash.inc ]; then . ${HOME}/google-cloud-sdk/completion.bash.inc; fi

. /opt/homebrew/opt/asdf/libexec/asdf.sh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/petur/Miniforge3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/petur/Miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/petur/Miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/petur/Miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
