# Atom intelligent Elixir Autocompletion for Autocomplete+

## Features
- Intelligent autocompletion of
  - Global modules and functions
  - Local project modules and functions (those which compile successfully)
- Type hints for
  - Arguments 
  - Return types
- Snippets for common structures

## Incoming features
- Local variables autcompletion
- Variable type inference (by priority)
  1. Assignment ( T = T )
  2. Expressions ( T = fn() :: T  , T = T + T) 
  3. Extraction ( [ T | [T] ] = [T] )
  4. Matching ( { T1, T2 } = {T1, T2} )
  5. Remote types
- Obvious type errors warnings ( Variable doesn't conform to required type / Extraction of non-parametric type)
- Feel free to suggest additional features at [issues page](https://github.com/iraasta/autocomplete-elixir/issues)


## Installation
Installation is done using Atom package manager or command

    apm install autocomplete-elixir

### Required modules
- [autocomplete+](https://atom.io/packages/autocomplete-plus)
- [autocomplete-snippets](https://atom.io/packages/autocomplete-snippets)
- [language-elixir](https://atom.io/packages/language-elixir)

### Recommended modules
- [term](https://atom.io/packages/term)
- [layout-manager](https://atom.io/packages/layout-manager)
