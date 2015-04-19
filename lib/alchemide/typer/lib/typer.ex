defmodule Typer do

  def get_type({op,ctx,args}) when is_atom(op) and is_list(ctx) and is_list(args) do

  end
  def get_type(a) when is_atom(a) ,                     do: :'atom()'
  def get_type(a) when is_binary(a) ,                   do: :'binary()'
  def get_type(a) when is_bitstring(a) ,                do: :'bitstring()'
  def get_type(a) when is_boolean(a) ,                  do: :'boolean()'
  def get_type(a) when is_float(a) ,                    do: :'float()'
  def get_type(a) when is_integer(a) ,                  do: :'integer()'
  def get_type(a) when is_list(a) ,                     do: :'list()'
  def get_type(a) when is_map(a) ,                      do: :'map()'
  def get_type(a) when is_nil(a) ,                      do: :'nil'
  def get_type(a) when is_number(a) ,                   do: :'number()'
  def get_type(a) when is_pid(a) ,                      do: :'pid()'
  def get_type(a) when is_port(a) ,                     do: :'port()'
  def get_type(a) when is_reference(a) ,                do: :'reference()'
  def get_type(a) when is_tuple(a) ,                    do: :'tuple()'
  def get_type(a) when is_function(a) ,                 do: :'function()'
  def get_type(_),                                      do: :'any()'
  
end
