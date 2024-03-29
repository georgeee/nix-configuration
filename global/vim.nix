{ config, lib, pkgs, ... }:

let
  # Vim keybindings:
  # <leader>: ,
  # ,f or ,F : open nerd tree
  # Ctrl+c : ghcmod completion
  # Shift-TAB: simple dictionary completion
  # , p to start paste mode (no nasty tabs on paste of indented text)
  vim-minizinc = pkgs.vimUtils.buildVimPlugin {
    name = "vim-minizinc";
    src = pkgs.fetchFromGitHub {
      owner = "vale1410";
      repo = "vim-minizinc";
      rev = "c422112efcde56d68d1a8cd84234db51406ad78d";
      sha256 = "1x759j9szqrqriay5xra7658n5qi8jsjlybn9z33d5ashydv4w20";
    };
  };

  my_vim = pkgs.vim_configurable.customize {
    name = "vim";
    vimrcConfig.vam.knownPlugins = pkgs.vimPlugins // {vim-minizinc=vim-minizinc;};
    vimrcConfig.vam.pluginDictionaries = [
      { names = [ "vim-tmux-navigator" "nerdtree" "julia-vim"
                  "vim-minizinc"
      # "neco-ghc" 
      "vimproc" # "ghcmod"
                      ];} ];
    vimrcConfig.customRC = ''
        set history=700
        
        " With a map leader it's possible to do extra key combinations
        " like <leader>w saves the current file
        if ! exists("mapleader")
          let mapleader = ","
        endif
        
        if ! exists("g:mapleader")
          let g:mapleader = ","
        endif
        
        " Leader key timeout
        set tm=2000
        
        " Allow the normal use of "," by pressing it twice
        noremap ,, ,
        
        " Use par for prettier line formatting
        set formatprg="PARINIT='rTbgqR B=.,?_A_a Q=_s>|' par\ -w72"
        
        " Set 7 lines to the cursor - when moving vertically using j/k
        set so=7
        
        " Turn on the WiLd menu
        set wildmenu
        " Tab-complete files up to longest unambiguous prefix
        set wildmode=list:longest,full
        
        " Always show current position
        set ruler
        set number
        
        " Show trailing whitespace
        set list
        " But only interesting whitespace
        if &listchars ==# 'eol:$'
          set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
        endif
        
        " Height of the command bar
        set cmdheight=1
        
        " Configure backspace so it acts as it should act
        set backspace=eol,start,indent
        set whichwrap+=<,>,h,l
        
        " Ignore case when searching
        set ignorecase
        
        " When searching try to be smart about cases
        set smartcase
        
        " Highlight search results
        set hlsearch
        
        " Makes search act like search in modern browsers
        set incsearch
        
        " Don't redraw while executing macros (good performance config)
        set lazyredraw
        
        " For regular expressions turn magic on
        set magic
        
        " Show matching brackets when text indicator is over them
        set showmatch
        " How many tenths of a second to blink when matching brackets
        set mat=2
        
        " No annoying sound on errors
        set noerrorbells
        set vb t_vb=
        
        " Default to mouse mode on
        set mouse=a
        
        " Use spaces instead of tabs
        set expandtab
        
        " Be smart when using tabs ;)
        set smarttab
        
        " 1 tab == 2 spaces
        set shiftwidth=2
        set tabstop=2
        
        " Linebreak on 500 characters
        set lbr
        set tw=500
        
        set ai "Auto indent
        set si "Smart indent
        set wrap "Wrap lines
        
        
        " Always show the status line
        set laststatus=2
        
        " Delete trailing white space on save
        func! DeleteTrailingWS()
          exe "normal mz"
          %s/\s\+$//ge
          exe "normal `z"
        endfunc
        
        augroup whitespace
          autocmd!
          autocmd BufWrite *.hs :call DeleteTrailingWS()
        augroup END
        
        
        set nobackup
        set nowb
        set noswapfile
        
        syntax enable

        " Close nerdtree after a file is selected
        let NERDTreeQuitOnOpen = 1
        
        function! IsNERDTreeOpen()
          return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
        endfunction

        function! ToggleFindNerd()
          if IsNERDTreeOpen()
            exec ':NERDTreeToggle'
          else
            exec ':NERDTreeFind'
          endif
        endfunction

        " If nerd tree is closed, find current file, if open, close it
        nmap <silent> <leader>f <ESC>:call ToggleFindNerd()<CR>
        nmap <silent> <leader>F <ESC>:NERDTreeToggle<CR>

        inoremap <S-TAB> <C-x><C-i>
        inoremap <C-c> <C-x><C-o>
        let g:necoghc_enable_detailed_browse = 1
        let g:haskellmode_completion_ghc = 0
        autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

        :set pastetoggle=<leader>p
    '';
  };
  # my_emacs = (pkgs.emacsPackagesNgGen pkgs.emacs25-nox).emacsWithPackages
  #   (epkgs: with epkgs.elpaPackages; with epkgs.melpaStablePackages; [
  #     evil
  #     evil-org
  #     evil-leader
  #     org
  #   ]);

in
{
   environment.systemPackages = [ my_vim ];
}
