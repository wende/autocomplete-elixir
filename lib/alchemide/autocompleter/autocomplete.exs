Application.put_env(:iex, :autocomplete_server, IEx.Server)

spec_to_ast = fn a,b -> Kernel.Typespec.spec_to_ast(a,b) end

y = fn f ->
  fun = fn x ->
    f.(fn y -> (x.(x)).(y) end)
  end
  fun.(fun)
end

y2 = fn f ->
  fun = fn x ->
    f.(fn y,z -> (x.(x)).(y,z) end)
  end
  fun.(fun)
end

replaceTypes = fn replaceType ->
  fn
    [{type, line, name, args} | types], typesMap ->
      case typesMap[name] do
          nil   -> [{type, line, name, replaceType.(args,typesMap)} | replaceType.(types,typesMap)]
          type  -> [type | replaceType.(types,typesMap)]
      end
    [type | types], typesMap -> [type | replaceType.(types, typesMap)]
    [], _ -> []
    any, _ -> any
  end
end
replaceTypes = y2.(replaceTypes)

zipFunSpec = fn
  (a, nil) -> a
  (a, []) -> a
  (a, b) ->
    [first | _] = b
    IO.inspect first
    IO.inspect a
    a <> "@" <> first
end
mapper = fn {{name, arity}, types}, typesMap ->

  spec = types
  |> replaceTypes.(typesMap)
  |> Enum.map(&spec_to_ast.(name, &1))
  |> Enum.map(&Macro.to_string/1)

  {Atom.to_string(name), spec}
end
reducer = fn {k, v}, acc ->
  Dict.put(acc,k,v)
end
getSpec = fn module ->
  type_aliases = (Kernel.Typespec.beam_types(module) || [])
  |> Enum.reduce %{}, fn
    ({_, {name, type, arg}},b) -> Map.put(b, name, type)
  end

  (Kernel.Typespec.beam_specs(module) || [])
  |> Enum.map(&mapper.(&1, type_aliases))
  |> Enum.reduce(%{}, reducer)
end

pairWithSpec = fn
input, fns, regex ->
  case Regex.match?(~r/\.|:/, input) do
    true ->
      mod = Regex.replace regex, input, ""
      {atom, _} = Code.eval_string(mod)
      specMap = getSpec.(atom)
      re = ~r/\/\d+\s*$/
      Enum.map(fns, fn a ->
        b = Dict.get(specMap, Regex.replace(re, to_string(a), ""))
        #IO.inspect b
        zipFunSpec.(to_string(a),b)
      end)
    false ->
      fns
  end
end

require = fn(file) ->
  try do
    Code.load_file(file)
    {"Ok", "", []}
  catch
    a,b -> {"Error #{inspect({a,b})}", "", []}
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
    {exists, one, pairWithSpec.(input, multi, ~r/\.\w*$/)}
  ("s", input) -> {"True", "" , Map.to_list getSpec.(String.to_atom("Elixir." <> input))}
  ("ea", input) ->
    ninput = ":"<>String.replace(input, ":", ".")
    {exists, one, multi} = IEx.Autocomplete.expand(Enum.reverse(to_char_list(ninput)))
    none = String.replace(List.to_string(one), ".", ":")
    nmulti = Enum.map multi, &String.replace(to_string(&1), ".", ":")
    #nmulti = Enum.map(multi, fn a -> String.replace(to_string(a),".",":") end)
    {exists, none, pairWithSpec.(ninput , nmulti, ~r/\.\w*$/)}
end

loop = fn(y) ->
  [command, input] = IO.gets("") |> String.split
  IO.puts formatResult.(execute.(command, input)) <> "\nok."
  y.(y)
end

System.argv
|> Enum.map(loadAll)
loop.(loop)
