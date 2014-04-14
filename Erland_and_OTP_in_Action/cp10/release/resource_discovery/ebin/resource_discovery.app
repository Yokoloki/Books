{application, resource_discovery,
    [{description, "A resource discovery utility"},
     {vsn, "0.1.0"},
     {modules, [rd_app, resource_discovery]},
     {registered, []},
     {applications, [kernel, stdlib]},
     {mod, {rd_app, []}}
    ]
}.
