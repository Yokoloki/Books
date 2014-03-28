-module(lib_misc).
-compile(export_all).

pmap(F, L) ->
    S = self(),
    Ref = erlang:make_ref(),
    Pids = lists:map(fun(I) -> spawn(fun() -> do_f(S, Ref, F, I) end) end, L),
    gather(Pids, Ref).
do_f(Parent, Ref, F, I) ->
    Parent ! {self(), Ref, (catch(F(I)))}.
gather([Pid | T], Ref) ->
    receive
        {Pid, Ref, Ret} -> [Ret | gather(T, Ref)]
    end;
gather([], _) -> [].


pmap1(F, L) ->
    S = self(),
    Ref = erlang:make_ref(),
    lists:foreach(fun(I) -> spawn(fun() -> do_f1(S, Ref, F, I) end) end, L),
    gather1(length(L), Ref, []).

do_f1(Parent, Ref, F, I) ->
    Parent ! {Ref, (catch F(I))}.

gather1(0, _, L) -> L;
gather1(N, Ref, L) ->
    receive
        {Ref, Ret} -> gather1(N-1, Ref, [Ret | L])
    end.

foreachWordInFile(File, F) ->
    case file:read_file(File) of
        {ok, Bin} -> foreachWordInString(binary_to_list(Bin), F);
        _ -> void
    end.
foreachWordInString(Str, F) ->
    case get_word(Str) of
        no -> void;
        {Word, Str1} ->
            F(Word),
            foreachWordInString(Str1, F)
    end.

get_word([H | T]) ->
    case isWordChar(H) of
        true -> collect_word(T, [H]);
        false -> get_word(T)
    end;
get_word([]) -> no.

collect_word([H|T] = All, L) ->
    case isWordChar(H) of
        true -> collect_word(T, [H|L]);
        false -> {lists:reverse(L), All}
    end;
collect_word([], L) ->
    {lists:reverse(L), []}.

isWordChar(X) when $A=<X, X=<$Z -> true;
isWordChar(X) when $0=<X, X=<$9 -> true;
isWordChar(X) when $a=<X, X=<$z -> true;
isWordChar(_) -> false.
