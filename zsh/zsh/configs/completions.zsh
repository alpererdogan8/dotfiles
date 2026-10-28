zstyle ':completion:*' insert-tab false
# fzf-tab: make the completion popup use the same graphite/orange palette as
# FZF_DEFAULT_OPTS (env.zsh), so Tab gets the identical theme in every shell.
zstyle ':fzf-tab:*' fzf-flags \
    --color=bg:#0f1113,bg+:#26282c,gutter:#0f1113 \
    --color=fg:#a49d94,fg+:#f2efe9 \
    --color=hl:#d65d0e,hl+:#ffab5e \
    --color=header:#d65d0e,info:#8b857d \
    --color=prompt:#d65d0e,pointer:#d65d0e,marker:#d65d0e,spinner:#d65d0e \
    --color=border:#33363a,separator:#33363a \
    --color=scrollbar:#55585c \
    --color=preview-bg:#0f1113,preview-fg:#a49d94 \
    --color=query:#f2efe9,disabled:#5a554e \

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd --color=always $realpath 2>/dev/null || ls --color=always $realpath'
