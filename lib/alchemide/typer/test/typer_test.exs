defmodule TyperTest do
  use ExUnit.Case

  test "Scoper" do
    res = Scoper.get_vars(quote do
      defmodule Specer do
        def get_spec(module) do
          mapper = fn {{name, _arity}, types} ->
            specs = types
            |> Enum.map(&(Kernel.Typespec.spec_to_ast(name, &1)))
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
      end
    end)
    assert res == ["v","module","name","types","k","specs","acc","mapper","reducer"]
  end

end
