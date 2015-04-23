defmodule Scoper do
  def close_block do

  end
  def get_variables({name, ctx, []}), do: []
  def get_variables({name, ctx, [arg|args]}) do
    [get_variables(arg) | get_variables({name, ctx, args})]
    |> List.flatten
    |> Enum.sca
  end
  def get_variables({name, ctx, other}) do
    {name, ctx, other}
  end
  def get_variables(other) do
    []
  end

end
