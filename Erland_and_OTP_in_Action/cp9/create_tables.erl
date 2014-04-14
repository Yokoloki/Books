-module(create_tables).
-export([init_tables/0]).
-record(user, {id, name}).
-record(project, {title, description}).
-record(contributor, {user_id, project_title}).

init_tables() ->
    mnesia:create_table(user, [{attributes, record_info(fields, user)}]),
    mnesia:create_table(project, [{attributes, record_info(fields, project)}]),
    mnesia:create_table(contributor, [{type, bag}, {attributes, record_info(fields, contributor)}]).
