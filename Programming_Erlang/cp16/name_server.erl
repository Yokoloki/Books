-module(name_server).
-export([init/0, add/2, whereis/1, handle/2, errf/0]).
-import(server3, [rpc/2]).

add(Name, Place) -> rpc(name_server, {add, Name, Place}).
whereis(Name) -> rpc(name_server, {whereis, Name}).
errf() -> rpc(name_server, {errf}).

init() -> dict:new().

handle({add, Name, Place}, Dict) -> {ok, dict:store(Name, Place, Dict)};
handle({whereis, Name}, Dict) -> {dict:find(Name, Dict), Dict};
handle({errf}, Dict) -> exit(1).
