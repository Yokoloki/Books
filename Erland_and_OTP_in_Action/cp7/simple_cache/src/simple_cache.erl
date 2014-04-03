-module(simple_cache).
-export([insert/2, lookup/1, delete/1]).

insert(Key, Value) ->
    case sc_store:lookup(Key) of
        {ok, Pid} ->
            sc_event:replace(Key, Value),
            sc_element:replace(Pid, Value);
        {error, _} ->
            {ok, Pid} = sc_element:create(Value),
            sc_event:create(Key, Value),
            sc_store:insert(Key, Pid)
    end.

lookup(Key) ->
    try
        {ok, Pid} = sc_store:lookup(Key),
        sc_event:lookup(Key),
        sc_element:fetch(Pid)
    catch
        _Class:_Exception ->
            {error, not_found}
    end.

delete(Key) ->
    case sc_store:lookup(Key) of
        {ok, Pid} -> 
            sc_event:delete(Key),
            sc_element:delete(Pid);
        {error, _Reason} -> ok
    end.

