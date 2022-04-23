-module(lang).
-export([trans/1]).

lang() -> uk.

trans(S) -> L = lang(), L:trans(S).
