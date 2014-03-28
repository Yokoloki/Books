-module(lib_find).
-export([files/3, files/5]).
-import(lists, [reverse/1]).

-include_lib("/usr/local/Cellar/erlang/R16B03-1/lib/erlang/lib/kernel-2.16.4/include/file.hrl").

files(Dir, Rexp, Recursive) ->
    {ok, Re} = re:compile(Rexp),
    reverse(files(Dir, Re, Recursive, fun(File, Acc) -> [File | Acc] end, [])).

files(Dir, Reg, Recursive, Fun, Acc) ->
    case file:list_dir(Dir) of
        {ok, Files} -> find_files(Files, Dir, Reg, Recursive, Fun, Acc);
        {error, _} -> Acc
    end.

find_files([File | T], Dir, Reg, Recursive, Fun, Acc0) ->
    FullName = filename:join([Dir, File]),
    case file_type(FullName) of
        regular ->
            case re:run(FullName, Reg) of
                {match, _} ->
                    Acc = Fun(FullName, Acc0),
                    find_files(T, Dir, Reg, Recursive, Fun, Acc);
                _ ->
                    find_files(T, Dir, Reg, Recursive, Fun, Acc0)
            end;
        directory ->
            case Recursive of 
                true ->
                    Acc = files(FullName, Reg, Recursive, Fun, Acc0),
                    find_files(T, Dir, Reg, Recursive, Fun, Acc);
                false ->
                    find_files(T, Dir, Reg, Recursive, Fun, Acc0)
            end;
        error ->
            find_files(T, Dir, Reg, Recursive, Fun, Acc0)
    end;
find_files([], _, _, _, _, A) -> A.

file_type(File) ->
    case file:read_file_info(File) of
        {ok, Facts} ->
            case Facts#file_info.type of
                regular -> regular;
                directory -> directory;
                _ -> error
            end;
        _ ->
            error
    end.
