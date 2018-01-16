-module(uk).
-compile(export_all).

trans("poll") -> <<"опитування"/utf8>>;
trans("logout") -> <<"вийти"/utf8>>;
trans("log in") -> <<"увійти"/utf8>>;

trans("create poll") ->	<<"створити опитування"/utf8>>;
trans("vote") -> <<"голосувати"/utf8>>;
trans("add alternative") -> <<"додати альтернативу"/utf8>>;

trans("the fastest way <br /> to make micro-desicions") ->
	<<"найшвидший спосіб<br />прийняти мікро-рішення"/utf8>>;

trans(S) -> S.