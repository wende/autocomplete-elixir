defmodule Test do


  defmacro a :: b do
    IO.puts("test #{a} #{b}")
    
  end


  def test(a,b) do
    a :: b
  end
end
