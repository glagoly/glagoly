-module(uk).
-compile(export_all).

% navbar
trans("create") -> <<"створити"/utf8>>;
trans("logout") -> <<"вийти"/utf8>>;

% poll
trans("Add my alternative") -> <<"Додати свій варіант"/utf8>>;
trans("Add") -> <<"Додати"/utf8>>;

trans("poll") -> <<"опитування"/utf8>>;

trans("log in") -> <<"увійти"/utf8>>;

trans("create poll") ->	<<"створити опитування"/utf8>>;
trans("vote") -> <<"голосувати"/utf8>>;
trans("add alternative") -> <<"додати альтернативу"/utf8>>;

trans("the fastest way <br /> to make micro-desicions") ->
	<<"найшвидший спосіб<br />прийняти мікро-рішення"/utf8>>;

trans("add most preferable alternative and rate it with +7") ->
	<<"додайте найкращу альтернативу і поставте їй +7"/utf8>>;
trans("add some less preferable alternatives and rate them with +5, +3, +1") ->
	<<"додайте менш привабливі альтернативи і поставте їм +5, +3, +1"/utf8>>;
trans("add other alternatives and leave them without rating") ->
	<<"додайте інші альтернативи, та залишти їх без оцінки"/utf8>>;

trans("add or rate the most preferable alternative with +7") ->
	<<"додайте або оберіть найкращу альтернативу і поставте їй +7"/utf8>>;
trans("rate less preferable alternatives with +5, +3, +1") ->
	<<"поставте менш привабливим альтернативам +5, +3, +1"/utf8>>;
trans("rate unacceptable alternative with -3") ->
	<<"поставте неприйнятній альтернативі оцінку -3"/utf8>>;

trans(S) -> en:trans(S).