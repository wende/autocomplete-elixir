# Atom intelligent Elixir Autocompletion for Autocomplete+

## Features
- Intelligent autocompletion of
  - Global modules and functions
  - Local project modules and functions (those which compile successfully)
- Type hints for
  - Arguments
  - Return types
- Type aliases replaced with primitive structures they represent
- Snippets for common structures

## Installation
Installation is done using Atom package manager or command

    apm install autocomplete-elixir

CAUTION: MAKE SURE TO HAVE `autocomplete-plus` PACKAGE INSTALLED


## Incoming features
- Local variables autocompletion
- Variable type inference (by priority)
  1. Assignment ( T = T )
  2. Expressions ( T = fn() :: T  , T = T + T)
  3. Extraction ( [ T | [T] ] = [T] )
  4. Matching ( { T1, T2 } = {T1, T2} )
  5. Remote types
- Obvious type errors warnings ( Variable doesn't conform to required type / Extraction of non-parametric type)
- Feel free to suggest additional features at [issues page](https://github.com/iraasta/autocomplete-elixir/issues)


### Common Errors

#### Package spits out a lot of errors on my MacOS
  It seems that MacOS has a lot of different safe measures which don't cooperate nicely with atom environment.  
  For optimal behaviour always start atom from command line instead of Finder.
  
#### `Failed to spawn command elixir. Make sure elixir is installed and in your PATH`  
  Let me guess. You're using MacOS. This happens when starting atom from Finder.
  Finder-started applications have no access to PATH variable. To go around that make
  sure to set "Elixir Path" in package configuration to Your absolute elixir executable
  path or start atom from command line instead.


### Required modules
- [autocomplete+](https://atom.io/packages/autocomplete-plus)
- [autocomplete-snippets](https://atom.io/packages/autocomplete-snippets)
- [language-elixir](https://atom.io/packages/language-elixir)

### Recommended modules
- [term](https://atom.io/packages/term)
- [layout-manager](https://atom.io/packages/layout-manager)
