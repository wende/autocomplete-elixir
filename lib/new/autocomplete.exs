require = fn(file) ->
  try do
    Code.require_file(file)
    {"Ok", "", []}
  catch
    _,_ -> {"Error", "", []}
  end
end

loadAll = fn(dir) ->
  dir
  |> Path.join("**/*.ex")
  |> Path.wildcard()
  |> Enum.map(require)
end

formatResult = fn({exists, one, multi}) ->
  [exists, one, Enum.join(multi, ",")] |> (&(Enum.join(&1, "|"))).()
end

execute = fn
  ("l", input) -> require.(input)
  ("a", input) -> IEx.Autocomplete.expand Enum.reverse to_char_list(input)
end

loop = fn(y) ->
  [command, input] = IO.gets("") |> String.split
  IO.puts formatResult.(execute.(command, input)) <> "\nok."
  y.(y)
end

System.argv
|> Enum.map(loadAll)
loop.(loop)
