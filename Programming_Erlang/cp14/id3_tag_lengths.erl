-module(id3_tag_lengths).
-export([file/1]).

file(File) ->
    case file:open(File, [read, binary, raw]) of
        {ok, S} ->
            Size = filelib:file_size(File),
            file:close(S),
            {0, Size - 128};
        Error->
            exit(Error)
    end.
