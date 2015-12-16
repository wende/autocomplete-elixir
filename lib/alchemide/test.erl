-module(test).

test() ->
  lists:map(some,text),
  application:behaviour_info(some),
  application:ensure_all_started(some),
  lists:append(123),
  1 + 2.
