" If a syntax is already loaded, quit
if exists("b:current_syntax")
  finish
endif

" Load the JSON syntax rules. This is the magic line! ✨
runtime! syntax/json.vim
