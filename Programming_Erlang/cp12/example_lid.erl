-module(example_lid).
-export([start/0, stop/0, twice/1, sum/2]).

start() ->
    start("example_drv").

start(SharedLib) ->
    case erl_ddll:load_driver(".", SharedLib) of 
        ok -> ok;
        {error, already_loaded} -> ok;
        _ -> exit({error, could_not_load_driver})
    end,
    spawn(fun() -> init(SharedLib) end).

init(SharedLib) ->
    register(example_lid, self()),
    Port = open_port({spawn, SharedLib}, []),
    loop(Port).

stop() ->
    example_lid ! stop.

twice(X) -> call_port({twice, X}).
sum(X, Y) -> call_port({sum, X, Y}).

call_port(Msg) ->
    example_lid ! {call, self(), Msg},
    receive
        {example_lid, Result} -> Result
    end.

loop(Port) ->
    receive
        {call, Caller, Msg} ->
            Port ! {self(), {command, encode(Msg)}},
            receive
                {Port, {data, Data}} ->
                    Caller ! {example_lid, decode(Data)}
            end,
            loop(Port);
        stop ->
            Port ! {self(), close},
            receive
                {Port, closed} -> exit(normal)
            end;
        {'EXIT', Port, Reason} ->
            io:format("~p~n", [Reason]),
            exit(port_terminated)
    end.

encode({twice, X}) -> [1, X];
encode({sum, X, Y}) -> [2, X, Y].

decode([Int]) -> Int.
