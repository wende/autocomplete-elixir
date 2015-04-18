
spec_to_ast = fn a,b -> Kernel.Typespec.spec_to_ast(a,b) end

zipFunSpec = fn
  (a, nil) -> a
  (a, []) -> a
  (a, b) ->
    [first | _] = b
    IO.inspect first
    IO.inspect a
    a <> "@" <> first
end

getSpec = fn module ->
  mapper = fn {{name, arity}, types} ->
    specs = types
    |> Enum.map(&(spec_to_ast.(name, &1)))
    |> Enum.map(&Macro.to_string/1)
    {Atom.to_string(name), specs}
  end
  reducer = fn {k, v}, acc ->
    Dict.put(acc,k,v)
  end

  Kernel.Typespec.beam_specs(module)
  |> Enum.map(mapper)
  |> Enum.reduce(%{}, reducer)
end

pairWithSpec = fn input, fns ->
  case String.contains?(input, ".") do
    true ->
      mod = Regex.replace ~r/\.\w*$/, input, ""
      {atom, _} = Code.eval_string("List")
      specMap = getSpec.(atom)
      re = ~r/\/\d+\s*$/
      Enum.map(fns, fn a ->
        b = Dict.get(specMap, Regex.replace(re, List.to_string(a), ""))
        #IO.inspect specMap
        #IO.inspect b
        zipFunSpec.(List.to_string(a),b)
      end)
    false ->
      fns
  end
end

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
  [exists, one, Enum.join(multi, ";")] |> (&(Enum.join(&1, "<>"))).()
end

execute = fn
  ("l", input) -> require.(input)
  ("a", input) ->
    {exists, one, multi} = IEx.Autocomplete.expand(Enum.reverse(to_char_list(input)))
    {exists, one, pairWithSpec.(input, multi)}
  ("s", input) -> getSpec.(String.to_atom("Elixir." <> input))
end

loop = fn(y) ->
  [command, input] = IO.gets("") |> String.split
  IO.puts formatResult.(execute.(command, input)) <> "\nok."
  y.(y)
end

System.argv
|> Enum.map(loadAll)
loop.(loop)
