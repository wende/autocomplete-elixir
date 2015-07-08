# Autocomplete-elixir's heart

## Running

To run the script use  
`elixir autocomplete.exs <path1, path2 ...>`  
Where paths are root directories of files that are being used during development.

### COMMANDS
Each command's format is:
`command param param2\n`

### Autocomplete
- `a #{prefix}` where prefix is a word currently beign typed in ex: `Enum.m`
- `ea #{prefix}` Same but for Erlang.
- `l #{path}` load a file to make it's modules available for autocompletion (Suggested after file saving)

#### Format of output

`exists<>one<>multi1;multi2;multi3`

Where:
- `exists` is a boolean  
- `one` is a oneliner suggestion that continues the typed word (f.i for word `Syst` suggestion will be `em`)
- `multi` when there is more than one suggestion (f.i for word `Enum.a` it's `all?/2;any?/2;at/3`)
