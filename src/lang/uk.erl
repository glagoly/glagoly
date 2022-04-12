-module(uk).
-export([trans/1]).

% navbar
trans("create") -> <<"створити"/utf8>>;
trans("logout") -> <<"вийти"/utf8>>;

% poll
trans("Add my alternative") -> <<"Додати свій варіант"/utf8>>;
trans("Add") -> <<"Додати"/utf8>>;
trans("Your name") -> <<"Ваше ім'я"/utf8>>;
trans("(required)") -> <<"(обов'язково)"/utf8>>;

trans("poll") -> <<"опитування"/utf8>>;

trans("log in") -> <<"увійти"/utf8>>;

trans("Create poll") ->	<<"Створити опитування"/utf8>>;
trans("Vote") -> <<"Голосувати"/utf8>>;
trans("View results") -> <<"Побачити результати"/utf8>>;

trans("add alternative") -> <<"додати альтернативу"/utf8>>;

trans("the fastest way <br /> to make micro-desicions") ->
	<<"найшвидший спосіб<br />прийняти мікро-рішення"/utf8>>;

trans(S) -> en:trans(S).
