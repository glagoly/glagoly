-module(matrix).
-compile(export_all).

new(Keys)-> 
	dict:from_list([{{Row, Col}, 0} || Row <- Keys, Col <- Keys]).

map(Fun, Matrix) -> 
	dict:map(fun({Row, Col}, Value) -> Fun(Row, Col, Value) end, Matrix).

fetch(Row, Col, Matrix) -> 
	dict:fetch({Row, Col}, Matrix).

update_counter(Row, Col, Increment, Matrix) ->
	dict:update_counter({Row, Col}, Increment, Matrix).
	
to_list(Matrix) -> 
	dict:to_list(Matrix).