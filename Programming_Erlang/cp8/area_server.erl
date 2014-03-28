-module(area_server).
-export([loop/0]).

loop() -> 
    receive
        {rectangle, Width, Ht} ->
            io:format("Area of rectangle is ~p~n", [Width*Ht]),
            loop();
        {circle, R} ->
            io:format("Area of circle is ~p~n", [3.14159*R*R]),
            loop();
        Other ->
            io:format("DONT KNOW THE AREA OF ~p~n", [Other]),
            loop()
    end.
