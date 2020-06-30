% A CFG to generate complex sentences for Monotonicity Inferences

%% Embedding depth is increased by:
% - relative clause

/* ==============================
   Main Rules
============================== */

% Sentence
% s([parse:s(NP,IV),depth:0,cond:_,sel:K]) -->
%     !,
%     np_sbj([parse:NP,depth:0,sel:K]),
%     iv([parse:IV,sel:K]).
% s([parse:s(NP,IV),depth:D,cond:no,sel:K]) -->
%     np_sbj([parse:NP,depth:D,sel:K]),
%     iv([parse:IV,sel:K]).

% s([parse:s(NP,IV),depth:0,cond:_,sel:K]) -->
%     !,
%     np_sbj([parse:NP,depth:0,sel:K]),
%     aux([parse:AUX,depth:0]),
%     iv([parse:IV,infl:base,sel:K]).
% s([parse:s(NP,IV),depth:D,cond:no,sel:K]) -->
%     np_sbj([parse:NP,depth:D,sel:K]),
%     aux([parse:AUX,depth:0]),
%     iv([parse:IV,infl:base,sel:K]).

s([parse:s(NP1,TV,NP2),depth:0,cond:_,sel:K]) -->
    !,
    np_sbj([parse:NP1,depth:0,sel:K]),
    tv([parse:TV,sel:K]),
    np_obj([parse:NP2,depth:0,sel:K]).
s([parse:s(NP1,TV,NP2),depth:D,cond:_,sel:K]) -->
    np_sbj([parse:NP1,depth:D,sel:K]),
    tv([parse:TV,sel:K]),
    np_obj([parse:NP2,depth:D,sel:K]).

% Noun Phrase
np_sbj([parse:np_sbj(DET,N),depth:0,sel:K]) -->
    !,
    det_up([parse:DET,num:NUM,sel:K]),
    n([parse:N,num:NUM,sel:K]).
% np_sbj([parse:np_sbj(DET,N,SBAR),depth:D1,sel:K]) -->
%    {D2 is D1 - 1},
%    det([parse:DET,num:NUM,sel:K]),
%    n([parse:N,num:NUM,sel:K]),
%    sbar([parse:SBAR,depth:D2,sel:K]).
np_obj([parse:np_obj(DET,N),depth:0,sel:K]) -->
    !,
    det([parse:DET,num:NUM,sel:K]),
    n([parse:N,num:NUM,sel:K]).
np_obj([parse:np_obj(DET,N,SBAR),depth:D1,sel:K]) -->
    {D2 is D1 - 1},
    det([parse:DET,num:NUM,sel:K]),
    n([parse:N,num:NUM,sel:K]),
    sbar([parse:SBAR,depth:D2,sel:K]).

% Sbar
sbar([parse:sbar(WHNP,TV,NP),depth:D,sel:K]) -->
    whnp_sbj([parse:WHNP,sel:K]),
    tv([parse:TV,sel:K]),
    np_obj([parse:NP,depth:D,sel:K]).
% sbar([parse:sbar(WHNP,IV),depth:0,sel:K]) -->
%     whnp_sbj([parse:WHNP,sel:K]),
%     iv([parse:IV,sel:K]).
sbar([parse:sbar(WHNP,NP,TV),depth:D,sel:K]) -->
    whnp_obj([parse:WHNP,sel:K]),
    np_sbj([parse:NP,depth:D,sel:K]),
    tv([parse:TV,sel:K]).
sbar([parse:sbar(NP,TV),depth:D,sel:K]) -->
    np_sbj([parse:NP,depth:D,sel:K]),
    tv([parse:TV,sel:K]).

/* ==============================
   Lexicon
============================== */

% Noun
n([parse:n(Surf),num:Num,sel:K]) -->
    {lex(n,[surf:Surf,num:Num])},
    Surf,
    {selector(K)}.

% Wh-NP
whnp_sbj([parse:whnp_sbj(Surf),sel:K]) -->
    {lex(whnp_sbj,[surf:Surf])},
    Surf,
    {selector(K)}.
whnp_obj([parse:whnp_obj(Surf),sel:K]) -->
    {lex(whnp_obj,[surf:Surf])},
    Surf,
    {selector(K)}.

% Determiner
det([parse:det(Surf),num:Num,sel:_]) -->
    {lex(det,[surf:Surf,num:Num])},
    Surf.

det_up([parse:det_up(Surf),num:Num,sel:_]) -->
    {lex(det_up,[surf:Surf,num:Num])},
    Surf.

% Intransitive Verb
iv([parse:iv(Surf),sel:K]) -->
    {lex(iv,[surf:Surf])},
    Surf,
    {selector(K)}.

% Transitive Verb
tv([parse:tv(Surf),sel:K]) -->
    {lex(tv,[surf:Surf])},
    Surf,
    {selector(K)}.

% Punctuation
punct([parse:punct(Surf)]) -->
    {lex(punct,[surf:Surf])},
    Surf.

/* ==============================
  Lexical Entries
============================== */

% Noun
lex(n,[surf:[bird],num:sing]).
lex(n,[surf:[birds],num:plur]).

lex(n,[surf:[rabbit],num:sing]).
lex(n,[surf:[rabbits],num:plur]).

lex(n,[surf:[lion],num:sing]).
lex(n,[surf:[lions],num:plur]).

lex(n,[surf:[dog],num:sing]).
lex(n,[surf:[dogs],num:plur]).

lex(n,[surf:[cat],num:sing]).
lex(n,[surf:[cats],num:plur]).

lex(n,[surf:[tiger],num:sing]).
lex(n,[surf:[tigers],num:plur]).

lex(n,[surf:[elephant],num:sing]).
lex(n,[surf:[elephants],num:plur]).

lex(n,[surf:[horse],num:sing]).
lex(n,[surf:[horses],num:plur]).

lex(n,[surf:[giraffe],num:sing]).
lex(n,[surf:[giraffes],num:plur]).

lex(n,[surf:[wolf],num:sing]).
lex(n,[surf:[wolves],num:plur]).

% WH-NP
lex(whnp_sbj,[surf:[that]]).
lex(whnp_sbj,[surf:[which]]).
lex(whnp_obj,[surf:[that]]).
lex(whnp_obj,[surf:[which]]).

lex(det_up,[surf:[some],num:sing]).

lex(det,[surf:[emptydet],num:plur]).
lex(det,[surf:[no],num:sing]).
lex(det,[surf:[some],num:sing]).
lex(det,[surf:[few],num:plur]).
lex(det,[surf:[a,few],num:plur]).
lex(det,[surf:[at,least,three],num:plur]).
lex(det,[surf:[less,than,three],num:plur]).
lex(det,[surf:[more,than,three],num:plur]).
lex(det,[surf:[at,most,three],num:plur]).

lex(iv,[surf:[ran]]).
lex(iv,[surf:[walked]]).
lex(iv,[surf:[cried]]).
lex(iv,[surf:[slept]]).
lex(iv,[surf:[swam]]).
lex(iv,[surf:[waited]]).
lex(iv,[surf:[danced]]).
lex(iv,[surf:[shoot]]).
lex(iv,[surf:[screamed]]).
lex(iv,[surf:[wasted]]).

lex(tv,[surf:[kissed]]).
lex(tv,[surf:[kicked]]).
lex(tv,[surf:[hit]]).
lex(tv,[surf:[cleaned]]).
lex(tv,[surf:[touched]]).
lex(tv,[surf:[loved]]).
lex(tv,[surf:[comforted]]).
lex(tv,[surf:[hurt]]).
lex(tv,[surf:[accepted]]).
lex(tv,[surf:[liked]]).

lex(punct,[surf:[[,]]]).

/* ==============================
  Auxiliary predicates
============================== */

yield([]).
yield([X|List]) :-
    write(X), write(' '), yield(List).

ptb(s(X,Y)) :-
    write('(S '), ptb(X), ptb(Y), write(')').
ptb(s(X,Y,Z)) :-
    write('(S '), ptb(X), ptb(Y), ptb(Z), write(')').
ptb(s(X,Y,Z,W)) :-
    write('(S '), ptb(X), ptb(Y), ptb(Z), ptb(W), write(')').

ptb(np_sbj(X,Y)) :-
    write('(NP-SBJ '), ptb(X), ptb(Y), write(')').
ptb(np_sbj(X,Y,Z)) :-
    write('(NP-SBJ '), ptb(X), ptb(Y), ptb(Z), write(')').
ptb(np_obj(X,Y)) :-
    write('(NP-OBJ '), ptb(X), ptb(Y), write(')').
ptb(np_obj(X,Y,Z)) :-
    write('(NP-OBJ '), ptb(X), ptb(Y), ptb(Z), write(')').

ptb(sbar(X,Y)) :-
    write('(SBAR '), ptb(X), ptb(Y), write(')').
ptb(sbar(X,Y,Z)) :-
    write('(SBAR '), ptb(X), ptb(Y), ptb(Z), write(')').

ptb(n([X|List])) :-
    write('(N '), write(X), ptb(List).
ptb(whnp_sbj([X|List])) :-
    write('(WHNP-SBJ '), write(X), ptb(List).
ptb(whnp_obj([X|List])) :-
    write('(WHNP-OBJ '), write(X), ptb(List).
ptb(det([X|List])) :-
    write('(DET '), write(X), ptb(List).
ptb(det_up([X|List])) :-
    write('(DET '), write(X), ptb(List).
ptb(iv([X|List])) :-
    write('(IV '), write(X), ptb(List).
ptb(tv([X|List])) :-
    write('(TV '), write(X), ptb(List).
ptb(punct([X|List])) :-
    write('(PUNCT '), write(X), ptb(List).

ptb([X|List]) :-
    write(' '), write(X), ptb(List).
ptb([]) :-
    write(')').

leq(N,N).
leq(_,0) :- !, fail.
leq(N1,N2):-
    M is N2 - 1, leq(N1,M).

le(N,M) :- leq(N,M), N =\= M.

selector(N) :- random_between(1,N,1).

/* ==============================
   Main Predicates
============================== */

% Generate a plain sentence with depth N
plain(N,K) :-
   s([parse:_,depth:N,cond:_,sel:K],Sentence,[]),
   yield(Sentence),nl,
   fail.

% Generate a parse tree with depth N
gen(N,K) :-
   s([parse:Tree,depth:N,cond:_,sel:K],_,[]),
   ptb(Tree),nl,
   fail.
