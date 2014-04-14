-module(resource_discovery).
-behaviour(gen_server).
-export([start_link/0, add_target_resource_type/1, add_local_resource/2, fetch_resources/1, trade_resources/0, check_resources/0, print_resources/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).
-record(state, {target_resource_types, local_resource_tuples, found_resource_tuples}).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
    {ok, #state{target_resource_types=[], local_resource_tuples=dict:new(), found_resource_tuples=dict:new()}}.

add_target_resource_type(Type) ->
    gen_server:cast(?SERVER, {add_target_resource_type, Type}).

add_local_resource(Type, Instance) ->
    gen_server:cast(?SERVER, {add_local_resource, {Type, Instance}}).

fetch_resources(Type) ->
    gen_server:call(?SERVER, {fetch_resources, Type}).

trade_resources() ->
    gen_server:cast(?SERVER, trade_resources).

check_resources() ->
    gen_server:cast(?SERVER, check_resources).

print_resources() ->
    gen_server:cast(?SERVER, print_resources).

handle_cast({add_target_resource_type, Type}, State) ->
    TargetTypes = State#state.target_resource_types,
    NewTargetTypes = [Type | TargetTypes],
    {noreply, State#state{target_resource_types=NewTargetTypes}};

handle_cast({add_local_resource, {Type, Instance}}, State) ->
    ResourceTuples = State#state.local_resource_tuples,
    NewResourceTuples = add_resource(Type, Instance, ResourceTuples),
    {noreply, State#state{local_resource_tuples=NewResourceTuples}};

handle_cast(trade_resources, State) ->
    ResourceTuples = State#state.local_resource_tuples,
    AllNodes = [node() | nodes()],
    lists:foreach(
        fun(Node) ->
                gen_server:cast({?SERVER, Node}, 
                    {trade_resources, {node(), ResourceTuples}})
        end,
        AllNodes),
    {noreply, State};

handle_cast({trade_resources, {ReplyTo, Remotes}},
            #state{local_resource_tuples=Locals, 
                   target_resource_types=TargetTypes,
                   found_resource_tuples=OldFound} = State) ->
    FilteredRemotes = resources_for_types(TargetTypes, Remotes),
    NewFound = add_resources(FilteredRemotes, OldFound),
    case ReplyTo of
        noreply -> ok;
        _ -> gen_server:cast({?SERVER, ReplyTo}, 
                {trade_resources, {noreply, Locals}})
    end,
    {noreply, State#state{found_resource_tuples=NewFound}};

handle_cast(check_resources, State) ->
    ResourceTuples = State#state.found_resource_tuples,
    NewFound = remove_lost_resources(dict:fetch_keys(ResourceTuples), ResourceTuples),
    {noreply, State#state{found_resource_tuples=NewFound}};

handle_cast(print_resources, State) ->
    io:format("Target~p~n", [State#state.target_resource_types]),
    io:format("Found ~p~n", [State#state.found_resource_tuples]),
    io:format("Local ~p~n", [State#state.local_resource_tuples]),
    {noreply, State}.

handle_call({fetch_resources, Type}, _From, State) ->
    io:format("try to fetch ~p~n", [Type]),
    {reply, dict:find(Type, State#state.found_resource_tuples), State}.

handle_info(_Msg, State) ->
    {noreply, State}.

terminate(Reason, _State) -> 
    io:format("Reason: ~p~n", [Reason]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

add_resource(Type, Resource, ResourceTuples) ->
    case dict:find(Type, ResourceTuples) of
        {ok, ResourceList} ->
            NewList = [Resource | lists:delete(Resource, ResourceList)],
            dict:store(Type, NewList, ResourceTuples);
        error ->
            dict:store(Type, [Resource], ResourceTuples)
    end.

add_resources([{Type, Resource} | T], ResourceTuples) ->
    add_resources(T, add_resource(Type, Resource, ResourceTuples));
add_resources([], ResourceTuples) ->
    ResourceTuples.

resources_for_types(Types, ResourceTuples) ->
    Fun = fun(Type, Acc) ->
            case dict:find(Type, ResourceTuples) of
                {ok, List} ->
                    [{Type, Instance} || Instance <- List] ++ Acc;
                error ->
                    Acc
            end
    end,
    lists:foldl(Fun, [], Types).

remove_lost_resources([], ResourceTuples) -> ResourceTuples;
remove_lost_resources([T | L], ResourceTuples) ->
    OldList = dict:fetch(T, ResourceTuples),
    NewList = lists:filter(fun(E) -> contains(nodes(), E) end, OldList),
    NewResourceTuples = 
        case NewList of
            [] -> dict:erase(T, ResourceTuples);
            _ -> dict:store(T, NewList, ResourceTuples)
        end,
    remove_lost_resources(L, NewResourceTuples).

contains([T | _L], T) -> true;
contains([_ | L], T) -> contains(L, T);
contains([], _T) -> false.
