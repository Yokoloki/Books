-module(test_mnesia).
-import(lists, [foreach/2]).
-compile(export_all).

-include_lib("/usr/local/Cellar/erlang/R16B03-1/lib/erlang/lib/stdlib-1.19.4/include/qlc.hrl").
-record(shop, {item, quantity, cost}).
-record(cost, {name, price}).
-record(design, {id, plan}).

start() ->
    mnesia:start(),
    mnesia:wait_for_tables([shop, cost, design], 20000).

do_this_once() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
    mnesia:create_table(shop, [{attributes, record_info(fields, shop)}]),
    mnesia:create_table(cost, [{attributes, record_info(fields, cost)}]),
    mnesia:create_table(design, [{attributes, record_info(fields, design)}]),
    mnesia:stop().

demo(select_shop) ->
    do(qlc:q([X || X <- mnesia:table(shop)]));
demo(select_some) ->
    do(qlc:q([{X#shop.item, X#shop.quantity} || X <- mnesia:table(shop)]));
demo(reorder) ->
    do(qlc:q([X#shop.item || X <- mnesia:table(shop), X#shop.quantity < 250]));
demo(join) ->
    do(qlc:q([X#shop.item || X <- mnesia:table(shop),
                             X#shop.quantity < 250,
                             Y <- mnesia:table(cost),
                             X#shop.item =:= Y#cost.name,
                             Y#cost.price < 2])).

add_shop_item(Name, Quantity, Cost) ->
    Row = #shop{item=Name, quantity=Quantity, cost=Cost},
    F = fun() -> mnesia:write(Row) end,
    mnesia:transaction(F).

remove_shop_item(Item) ->
    Oid = {shop, Item},
    F = fun() -> mnesia:delete(Oid) end,
    mnesia:transaction(F).

farmer(Nwant) ->
    F = fun() ->
            [Apple] = mnesia:read({shop, apple}),
            Napples = Apple#shop.quantity,
            Apple1 = Apple#shop{quantity = Napples + 2*Nwant},
            mnesia:write(Apple1),
            [Orange] = mnesia:read({shop, orange}),
            NOranges = Orange#shop.quantity,
            if NOranges >= Nwant ->
                    N1 = NOranges - Nwant,
                    Orange1 = Orange#shop{quantity = N1},
                    mnesia:write(Orange1);
                true ->
                    mnesia:abort(oranges)
            end
    end,
    mnesia:transaction(F).

example_tables() ->
    [
        {shop, apple, 20, 2.3},
        {shop, orange, 100, 3.8},
        {shop, pear, 200, 3.6},
        {shop, banana, 420, 4.5},
        {shop, potato, 2456, 1.2},
        {cost ,apple, 1.5},
        {cost, orange, 2.4},
        {cost, pear, 2.2},
        {cost, banana, 1.5},
        {cost, potato, 0.6}
    ].

reset_tables() ->
    mnesia:clear_table(shop),
    mnesia:clear_table(cost),
    F = fun() -> foreach(fun mnesia:write/1, example_tables()) end,
    mnesia:transaction(F).

do(Q) ->
    F = fun() -> qlc:e(Q) end,
    {atomic, Val} = mnesia:transaction(F),
    Val.

add_plans() ->
    D1 = #design{id = {joe,1}, plan = {circle, 10}},
    D2 = #design{id = fred, plan = {rectangle, 10, 5}},
    D3 = #design{id = {jane, {house, 23}},
                 plan = {house, [{floor, 1}, [{doors, 3}, {windows, 12}]]}},
    F = fun() -> mnesia:write(D1), mnesia:write(D2), mnesia:write(D3) end,
    mnesia:transaction(F).

get_plan(PlanId) ->
    F = fun() -> mnesia:read({design, PlanId}) end,
    mnesia:transaction(F).

