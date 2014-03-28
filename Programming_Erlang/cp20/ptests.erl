-module(ptests).
-export([tests/1, fib/1]).
-import(lists, [map/2]).
-import(lib_misc, [pmap/2]).

tests([N]) ->
    Nsched = list_to_integer(atom_to_list(N)),
    run_tests(1, Nsched).

run_tests(N, Nsched) ->
    case test(N) of
        stop ->
            init:stop();
        Val ->
            io:format("~p.~n", [{Nsched, Val}]),
            run_tests(N+1, Nsched)
    end.

test(1) ->
    seed(),
    S = lists:seq(1, 100),
    L = map(fun(_) -> mkList(1000) end, S),
    {Time1, S1} = timer:tc(lists, map, [fun lists:sort/1, L]),
    {Time2, S2} = timer:tc(lib_misc, pmap, [fun lists:sort/1, L]),
    {sort, Time1, Time2, equal(S1, S2)};
test(2) ->
    L = lists:duplicate(100, 27),
    {Time1, S1} = timer:tc(lists, map, [fun ptests:fib/1, L]),
    {Time2, S2} = timer:tc(lib_misc, pmap, [fun ptest:fib/1, L]),
    {fib, Time1, Time2, equal(S1, S2)};
test(3) ->
    stop.

equal(_S, _S) -> true;
equal(_S1, _S2) -> false.

fib(0) -> 1;
fib(1) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

seed() -> random:seed(44,55,66).

mkList(K) -> mkList(K, []).
mkList(0, L) -> L;
mkList(N, L) -> mkList(N-1, [random:uniform(1000000) | L]).
