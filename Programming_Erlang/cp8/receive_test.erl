-module(receive_test).
-export([start/0, send/2, loop/1]).

send(Pid, Message) ->
    Pid ! {self(), Message}.

rpc(Pid, Request) ->
    Pid ! Request,
    receive
        {Pid, Response} ->
            Response
    end.

start() ->
    spawn(?MODULE, loop, [1]).

loop(N) ->
    receive
        {Pid, Message} when N>3 ->
            Pid ! {response, Message, N},
            io:format("###Receive ~p ~p~n", [Message, N]),
            loop(1)
    after 9000 ->
        io:format("__Timeout la...~p ~n", [N]),
        loop(N+1)
    end.
