-module(lang).
-compile(export_all).

lang() -> uk.

trans(S) -> L = lang(), L:trans(S).