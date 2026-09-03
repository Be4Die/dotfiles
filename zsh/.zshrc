# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/cachyos-zsh-config/cachyos-config.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="$HOME/.local/bin:$PATH"
alias cls="clear"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/michael/.lmstudio/bin"
# End of LM Studio CLI section

alias task='go-task'
export PATH="$PATH:$HOME/go/bin"


# Added by Antigravity CLI installer
export PATH="/home/michael/.local/bin:$PATH"
___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi

# .NET tools
[[ -d "$HOME/.dotnet/tools" ]] && export PATH="$PATH:$HOME/.dotnet/tools"

# Default browser
export BROWSER=firefox

# NVIDIA CUDA (Desktop PC)
if [[ -d "/opt/cuda-11.8" ]]; then
    export CUDA_HOME="/opt/cuda-11.8"
    export PATH="$CUDA_HOME/bin:$PATH"
    export LD_LIBRARY_PATH="$CUDA_HOME/targets/x86_64-linux/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi
