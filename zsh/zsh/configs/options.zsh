HISTFILE=$ZDOTDIR/zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt autocd correct interactivecomments magicequalsubst notify numericglobsort promptsubst
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups
setopt hist_expire_dups_first hist_find_no_dups

export FZF_DEFAULT_OPTS="--color=bg+:#d0d0d0,bg:#d0d0d0,spinner:#00fcb9,hl:#ff0063,fg:#ededfe,header:#ff948b,info:#ffe900,pointer:#ff57fd,marker:#00ffed,fg+:#ededff,prompt:#00a4ff,hl+:#ff0063,border:#d0d0d0 --layout=reverse --border --info=inline --height=100% --pointer='▶'"

export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=plain {} 2>/dev/null || cat {}' --preview-window='right:50%:border-left'"

export FZF_ALT_C_OPTS="--preview 'lsd --tree --color=always {} 2>/dev/null || ls -l --color=always {}' --preview-window='right:50%:border-left'"

export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window='right:50%:wrap:border-left'"

export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --preview 'lsd --color=always --grid {} 2>/dev/null || ls --color=always {}' --preview-window='right:50%:border-left'"

