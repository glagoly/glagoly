-module(uk).
-export([trans/1]).

% navbar
trans("create") -> <<"створити"/utf8>>;
trans("Log out") -> <<"Вийти"/utf8>>;
trans("edit") -> <<"редагувати"/utf8>>;

trans("Remove") -> <<"Видалити"/utf8>>;
trans("Cancel") -> <<"Відмінити"/utf8>>;
trans("Save") -> <<"Зберегти"/utf8>>;

trans("My polls") -> <<"Мої опитування"/utf8>>;
trans("Results") -> <<"Результати"/utf8>>;

trans(title_samples) -> title_samples();
trans(title_sample) -> <<"Де і коли зустрічаємось?"/utf8>>;

trans("Create your poll") -> <<"Створити своє опитування"/utf8>>;
trans("Try:") -> <<"Спробуйте:"/utf8>>;

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

trans(S) -> en:trans(S).

title_samples() -> [
	<<"Де і коли зустрічаємось?"/utf8>>,
	<<"Що робимо?"/utf8>>,
	<<"Куди їдемо?"/utf8>>
].