defmodule Scoper do
  def close_block (code) do

  end

  def compile(string) do
    handle(Code.string_to_quoted string )
  end

  def handle {:error, {line, msg, _}} do
    
  end
  def handle {:ok, code} do

  end

  def get_variables({a,_b,c}) when not is_list(c) do
    [a]
  end
  def get_variables(a) when is_tuple(a) do
    get_variables(Tuple.to_list(a))
  end
  def get_variables([h|t]) do
    [get_variables(h) | get_variables(t)]
  end
  def get_variables(_) do
    []
  end
  def get_vars(code) do
    get_variables(code)
    |> List.flatten()
    |> Enum.into(HashSet.new())
    |> Set.to_list()
    |> Enum.filter(fn a -> Regex.match?(~r/^[^_]/, to_string(a)) end)
    |> Enum.map(&to_string/1)
  end


  # def get_variables(other) do
  #   other
  # end


end
