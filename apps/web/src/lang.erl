-module(lang).
-compile(export_all).

lang() -> en.

trans(S) -> L = lang(), L:trans(S).