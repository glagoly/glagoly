<?php

// I'm so good in Erlang that can't get how algorithm works
// so here is PHP implementation


// %% P[i,j] = {N[i,j], N[j,i]}
// init(N) -> 
//  lists:zipwith(fun lists:zip/2, N, transpose(N)).
function init($n)
{
    $p = [];
    for ($j = 0; $j < count($n); $j++) {
        $p[] = [];
        for ($i = 0; $i < count($n[$j]); $i++) {
            $p[$j][] = [$n[$j][$i], $n[$i][$j]];
        }
    }

    return $p;
}

// %% path strong comprasion >_d by winning votes
// gt({E,F}, {G,H}) when E > F, G =< H -> true;
// gt({E,F}, {G,H}) when E >= F, G < H -> true;
// gt({E,F}, {G,H}) when E > F, G > H, E > G -> true;
// gt({E,F}, {G,H}) when E > F, G > H, E =:= G, F < H ->true;
// gt(_,_) -> false.
function gt($a, $b)
{
    list($e, $f) = $a;
    list($g, $h) = $b;

    if ($g == null) {
        return true;
    }
    if ($e == null) {
        return false;
    }
    if (($e > $f) && ($g <= $h)) {
        return true;
    }
    if (($e >= $f) && ($g < $h)) {
        return true;
    }
    if (($e > $f) && ($g > $h) && ($e > $g)) {
        return true;
    }
    if (($e > $f) && ($g > $h) && ($e == $g) && ($f < $h)) {
        return true;
    }

    return false;
}

// min_d(A,B) -> case gt(A,B) of true -> B; _ -> A end.
function min_d($a, $b)
{
    return gt($a, $b) ? $b : $a;
}

function print_p($p)
{
    foreach ($p as $row) {
        echo '[';
        foreach ($row as $cell) {
            echo '{' . $cell[0] . ',' . $cell[1] . '},';
        }
        echo "]\n";
    }
}

function strongest_path($p)
{
    $l = count($p);
    for ($i = 0; $i < $l; $i++) {
        for ($j = 0; $j < $l; $j++) {
            if ($i == $j) {
                continue;
            }
            for ($k = 0; $k < $l; $k++) {
                if (($i == $k) || ($j == $k)) {
                    continue;
                }

                $min = min_d($p[$j][$i], $p[$i][$k]);
                if (gt($min, $p[$j][$k])) {
                    $p[$j][$k] = $min;
                }
            }
        }
    }

    return $p;
}


$n = [[null, 8, 14, 10],
      [13, null, 6, 2],
      [7, 15, null, 12],
      [11, 19, 9, null]];

print_p(strongest_path(init($n)));
