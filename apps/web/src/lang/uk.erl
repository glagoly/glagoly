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
trans("add your own alternative") ->
  <<"додайте свій, найкращий в світі, варіанти"/utf8>>;

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
trans("view results") ->
  <<"подивитись результати"/utf8>>;

trans("science magic inside") ->
  <<"науковий підхід під капотом"/utf8>>;
trans("glagoly simple to use, but backed by voting science:") ->
  <<"для обчислення рішення glagoly використовує"/utf8>>;
trans("schulze method for ranking votes;") ->
  <<"Метод Шульце"/utf8>>;
trans("robson rotation to eliminate “donkey voting”.") ->
  <<"Метод ротації Робсона"/utf8>>;
trans("free as in speech") ->
  <<"Опен сорс"/utf8>>;
trans("glagoly is free software. run for any purpose, study, change, and distribute it.") ->
  <<"glagoly це проєкт з відкритим вихідним кодом"/utf8>>;

trans("easy meeting schedule") ->
  <<"легко домовитись про час та формат зустрічі"/utf8>>;
trans("choose meeting time, place and activity in one poll:") ->
  <<"напирклад, якщо ви хочете домовитися про щоденний спортік на роботі"/utf8>>;
trans("play football on saturday morning;") ->
  <<"стоїмо в планці о 16:00"/utf8>>;
trans("make a barbecue on saturday morning;") ->
  <<"стоїмо в планці о 17:00"/utf8>>;
trans("drink beer at bar on friday evening.") ->
  <<"пів години йоги на 9:00"/utf8>>;

trans("fun rated lists") ->
  <<"сортуйте списки в порядку важливості"/utf8>>;
trans("create rated lists for fun. choose cocktails for your next party:") ->
  <<"оберіть список коктейлів для наступної вечірки на основі горілки і пива"/utf8>>;
trans("cosmopolitan;") ->
  <<"Йорш"/utf8>>;
trans("sex on the beach;") ->
  <<"Cльози Галадріель"/utf8>>;
trans("long island iced tea.") ->
  <<"Пивний негідник"/utf8>>;

trans("wise collective decisions") ->
  <<"зважене колективне рішення"/utf8>>;
trans("hear and choose all alternatives. not only 'yes', 'no' or abstain:") ->
  <<"почуєте всі пропозиції, учасники голосування можуть додавати свої варіанти для голосування"/utf8>>;
trans("paint fence in red;") ->
  <<"пофарбувати стіну в червоний"/utf8>>;
trans("paint fence in blue;") ->
  <<"пофарбувати стіну в синій"/utf8>>;
trans("remove fence and make bicycle parking.") ->
  <<"знести стіну і зробити парковку для велосипедів"/utf8>>;




trans("make decision in less then 5 minutes") ->
  <<"прийняти рішення за 5 хвилин"/utf8>>;


trans(S) -> en:trans(S).
