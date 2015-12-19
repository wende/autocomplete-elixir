defmodule Test do


  defmacro a :: b do
    IO.puts("test #{a} #{b}")
  end


  def test(a,b) do
    Test.test()
  end
end
