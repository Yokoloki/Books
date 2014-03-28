-module(lib_primes).
-export([make_prime/1, make_prime_o/1]).

make_prime(1) ->
    lists:nth(random:uniform(5), [1, 2, 3, 5, 7]);
make_prime(K) when K > 0 ->
    new_seed(),
    %io:format("Generating a ~w digit prime", [K]),
    make_prime_helper(K).

make_prime_helper(K) ->
    N = make_random_pesudo(K),
    case is_prime(N) of
        true -> N;
        false -> make_prime_helper(K)
    end.

make_prime_o(1) ->
    lists:nth(random:uniform(5), [1, 2, 3, 5, 7]);
make_prime_o(K) when K > 0 ->
    new_seed(),
    N = make_random_pesudo(K),
    if
        N > 3 ->
            %io:format("Generating a ~w digit prime", [K]),
            MaxTries = N -3,
            P1 = make_prime(MaxTries, N),
            P1;
        true ->
            make_prime_o(K)
    end.

make_prime(0, _) -> exit(impossible);
make_prime(K, P) ->
    case is_prime(P) of
        true -> P;
        false -> make_prime(K-1, P+2)
    end.

is_prime(D) ->
    new_seed(),
    case prime_pretest(D) of
        false -> false;
        true -> is_prime(D, 100)
    end.
is_prime(D, Ntests) ->
    N = length(integer_to_list(D)) -1,
    is_prime(Ntests, D, N).
is_prime(0, _, _) -> true;
is_prime(Ntests, N, Len) ->
    K = random:uniform(Len),
    A = make_random_int(K),
    if
        A<N ->
            case lib_lin:pow(A, N, N) of
                A -> is_prime(Ntests-1, N, Len);
                _ -> false
            end;
        true ->
            is_prime(Ntests, N, Len)
    end.

prime_pretest(D) ->
    R3 = num_sum(D) rem 3,
    R5 = D rem 5,
    if
        (R3 =:= 0) or (R5 =:= 0) -> false;
        true -> true
    end.

num_sum(0) -> 0;
num_sum(N) -> num_sum(N div 10) + N rem 10.

make_random_int(N) -> 
    new_seed(), 
    make_random_int(N, 0).

make_random_int(0, D) -> D;
make_random_int(N, 0) ->
    make_random_int(N-1, random:uniform(9));
make_random_int(N, D) ->
    make_random_int(N-1, D*10+(random:uniform(10)-1)).

make_random_pesudo(N) ->
    make_random_int(N-1)*10 + lists:nth(random:uniform(4), [1, 3, 7, 9]).

new_seed() ->
    {_, _, X} = erlang:now(),
    {H, M, S} = time(),
    H1 = H * X rem 32767,
    M1 = M * X rem 32767,
    S1 = S * X rem 32767,
    put(random_seed, {H1, M1, S1}).
