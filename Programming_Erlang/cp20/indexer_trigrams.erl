-module(indexer_trigrams).
-export([open/0, close/1, is_word/2]).

open() ->
    {ok, I} = ets:file2tab(filename:dirname(code:which(?MODULE)) ++ "/trigramsS.tab"),
    I.

close(Tab) -> ets:delete(Tab).

is_word(Tab, Str) -> is_word1(Tab, "\s"++Str++"\s").
is_word1(Tab, [_, _, _]=X) -> is_this_a_trigram(Tab, X);
is_word1(Tab, [A, B, C| D]) ->
    case is_this_a_trigram(Tab, [A, B, C]) of
        true -> is_word1(Tab, [B, C| D]);
        false -> false
    end;
is_word1(_, _) -> false.

is_this_a_trigram(Tab, X) ->
    case ets:lookup(Tab, list_to_binary(X)) of
        [] -> false;
        _ -> true
    end.

