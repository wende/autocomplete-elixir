# Atom intelligent Elixir Autocompletion for Autocomplete+

![Image of autocomplete-elixir](https://raw.githubusercontent.com/wende/autocomplete-elixir/master/pics/presentation.png)

## Features
- Intelligent autocompletion of
  - Global modules and functions
  - Local project modules and functions (those which compile successfully)
- Type hints for
  - Arguments
  - Return types
- Type aliases replaced with primitive structures they represent
- Snippets for common structures
- `do`/`fn` -> `end` highlighting
- Jump to local function/macro defintion with `alt-.` and back with `alt-,`

## Installation
Installation is done using Atom package manager or command

    apm install autocomplete-elixir

CAUTION: MAKE SURE TO HAVE `autocomplete-plus` PACKAGE INSTALLED


## Incoming features
### 1.6
- Jump to definition out of local module

Feel free to suggest additional features at [issues page](https://github.com/iraasta/autocomplete-elixir/issues)

### Common Errors

#### Package spits out a lot of errors on my OSX
  It seems that OSX has a lot of different safe measures which don't cooperate nicely with atom environment.  
  Make sure you've got both erlang and elixir installed and paths set up in package settings:
  ![Image of autocomplete-elixir](https://raw.githubusercontent.com/wende/autocomplete-elixir/master/pics/Screen.Shot.2016-02-19.at.17.12.58.png)

  
  For optimal behaviour always start atom from command line instead of Finder.
  
#### `Failed to spawn command elixir. Make sure elixir is installed and in your PATH`  
  Let me guess. You're using OSX. This happens when starting atom from Finder.
  Finder-started applications have no access to PATH variable. To go around that make
  sure to set "Elixir Path" in package configuration to Your absolute elixir executable
  path or start atom from command line instead.


### Required modules
- [autocomplete+](https://atom.io/packages/autocomplete-plus)
- [autocomplete-snippets](https://atom.io/packages/autocomplete-snippets)
- [language-elixir](https://atom.io/packages/language-elixir)

### Troubleshooting
1. Make sure you've got both Elixir and Erlang installed
2. Make sure you've got both paths set up in settings
You can check both things by running:
`which elixir` -> /usr/local/bin/elixir
`which erl` -> /usr/local/bin/erl
And insert the whole path of elixir but only folder path of erl
![Image of autocomplete-elixir](https://raw.githubusercontent.com/wende/autocomplete-elixir/master/pics/Screen.Shot.2016-02-19.at.17.12.58.png)
3. Make sure You've got Elixir-language package installed
4. Try running atom from the CLI
5. Read existing issues ;)
