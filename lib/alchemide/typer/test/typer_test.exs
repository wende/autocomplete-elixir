defmodule TyperTest do
  use ExUnit.Case

  test "the truth" do
    assert 1 + 1 == 2
  end
  test "simple expression value" do
    assert Typer.get_type(s_to_ast("1")) == :'integer()'
    assert Typer.get_type(s_to_ast(":atom")) == :'atom()'
  end

  def s_to_ast(string) do
    {:ok, ast} = Code.string_to_quoted(string)
    ast
  end
end
