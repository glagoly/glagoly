-module(uk).
-compile(export_all).

trans("create poll") ->
	<<"створити опитування"/utf8>>;

trans("the fastest way <br /> to make micro-desicions") ->
	<<"найшвидший спосіб<br />прийняти мікро-рішення"/utf8>>;

trans(S) -> S.