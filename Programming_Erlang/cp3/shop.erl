-module(shop).
-export([cost/1, total/1]).
-import(lists, [map/2, sum/1]).

cost(oranges) -> 5;
cost(newspaper) -> 8;
cost(apples) -> 2;
cost(pears) -> 9;
cost(milk) -> 12.

total(L) ->
    sum(map(fun({What, N}) -> cost(What)*N end, L)).
