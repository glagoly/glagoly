-module(uk).
-compile(export_all).

trans("poll") -> <<"голосування"/utf8>>;
trans("logout") -> <<"вийти"/utf8>>;
trans("log in") -> <<"увійти"/utf8>>;

trans("create poll") ->	<<"створити голосування"/utf8>>;
trans("vote") -> <<"Проголосувати!"/utf8>>;
trans("add alternative") -> <<"додати свій варіант"/utf8>>;

trans("the fastest way <br /> to make micro-desicions") ->
	<<"Найшвидший спосіб<br />для прийняття колективних рішень"/utf8>>;

trans("add most preferable alternative and rate it with +7") ->
	<<"додайте найкращий для вас варіант і оцініть його +7"/utf8>>;
trans("add some less preferable alternatives and rate them with +5, +3, +1") ->
	<<"додайте менш підходящі для вас варіант і оцініть їх +5, +3, +1"/utf8>>;
trans("add other alternatives and leave them without rating") ->
	<<"додайте інші варіанти"/utf8>>;

trans("add or rate the most preferable alternative with +7") ->
	<<"поставте +7(крайне праве положення повзунка)   варіанту який для вас найкращий, просто гарячий періжечок, краще не придумати"  /utf8>>;
trans("rate less preferable alternatives with +5, +3, +1") ->
	<<"поставте від +1 до +6 іншим варіантам"/utf8>>;
trans("rate unacceptable alternative with -3") ->
	<<"поставте -1 варіантам які взагалі не годятся, поставте -3(крайне ліве положення) варіанту від якого у вас підгоріло"/utf8>>;

trans("change vote") ->
  <<"змінити свої оцінки"/utf8>>;
trans("invite others") ->
  <<"запросити інших"/utf8>>;
trans("anyone with this link can vote or add alternatives") ->
  <<"будь хто за цим посиланням зможе голосувати і додавати своії варіанти"/utf8>>;
trans("My alternative") ->
  <<"Додайте свій варіант"/utf8>>;
trans("Your name (required)") ->
  <<"Впишіть ваше ім'я та прізвище"/utf8>>;
trans("name meainingful for other voters") ->
  <<"щоб інші учасники голосування розуміли хто є хто"/utf8>>;


trans(S) -> en:trans(S).
