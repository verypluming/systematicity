% A CFG to generate simple sentences for Monotonicity Inferences
% with semantic composition

:- use_module(betaConversion,[betaConvert/2]).
:- use_module(fol2tptp,[fol2tptp/2]).
:- use_module(comsemPredicates,[infix/0,
                                prefix/0,
                                printRepresentations/1]).

/* ==============================
   Main Rules
============================== */

% Sentence
s([parse:s(NP,IV),sem:SR,depth:0,cond:_,sel:K]) -->
    !,
    np_sbj([parse:NP,sem:SR1,depth:0,sel:K]),
    iv([parse:IV,sem:SR2,sel:K]),
    {combine(s:SR,[np:SR1,iv:SR2])}.
s([parse:s(NP,IV),sem:SR,depth:D,cond:no,sel:K]) -->
    np_sbj([parse:NP,sem:SR1,depth:D,sel:K]),
    iv([parse:IV,sem:SR2,sel:K]),
    {combine(s:SR,[np:SR1,iv:SR2])}.

% s([parse:s(NP,IV),depth:0,cond:_,sel:K]) -->
%     !,
%     np_sbj([parse:NP,depth:0,sel:K]),
%     aux([parse:AUX,depth:0]),
%     iv([parse:IV,infl:base,sel:K]).
% s([parse:s(NP,IV),depth:D,cond:no,sel:K]) -->
%     np_sbj([parse:NP,depth:D,sel:K]),
%     aux([parse:AUX,depth:0]),
%     iv([parse:IV,infl:base,sel:K]).

% s([parse:s(NP1,TV,NP2),depth:0,cond:_,sel:K]) -->
%     !,
%     np_sbj([parse:NP1,depth:0,sel:K]),
%     tv([parse:TV,sel:K]),
%     np_obj([parse:NP2,depth:0,sel:K]).
% s([parse:s(NP1,TV,NP2),depth:D,cond:_,sel:K]) -->
%     np_sbj([parse:NP1,depth:D,sel:K]),
%     tv([parse:TV,sel:K]),
%     np_obj([parse:NP2,depth:D,sel:K]).

% Noun Phrase
np_sbj([parse:np_sbj(DET,N),sem:SR,depth:0,sel:K]) -->
    !,
    det([parse:DET,sem:SR1,num:NUM,sel:K]),
    n([parse:N,sem:SR2,num:NUM,sel:K]),
    {combine(np:SR,[det:SR1,n:SR2])}.
np_sbj([parse:np_sbj(DET,N,SBAR),sem:SR,depth:D1,sel:K]) -->
    {D2 is D1 - 1},
    det([parse:DET,sem:SR1,num:NUM,sel:K]),
    n([parse:N,sem:SR2,num:NUM,sel:K]),
    sbar([parse:SBAR,sem:SR3,depth:D2,sel:K]),
    {combine(np:SR,[det:SR1,n:SR2,sbar:SR3])}.
np_obj([parse:np_obj(DET,N),sem:SR,depth:0,sel:K]) -->
    !,
    det([parse:DET,sem:SR1,num:NUM,sel:K]),
    n([parse:N,sem:SR2,num:NUM,sel:K]),
    {combine(np:SR,[det:SR1,n:SR2])}.
np_obj([parse:np_obj(DET,N,SBAR),sem:SR,depth:D1,sel:K]) -->
    {D2 is D1 - 1},
    det([parse:DET,sem:SR1,num:NUM,sel:K]),
    n([parse:N,sem:SR2,num:NUM,sel:K]),
    sbar([parse:SBAR,sem:SR3,depth:D2,sel:K]),
    {combine(np:SR,[det:SR1,n:SR2,sbar:SR3])}.

% Sbar
sbar([parse:sbar(WHNP,TV,NP),sem:SR,depth:D,sel:K]) -->
    whnp_sbj([parse:WHNP,sel:K]),
    tv([parse:TV,sem:SR1,sel:K]),
    np_obj([parse:NP,sem:SR2,depth:D,sel:K]),
    {combine(sbar:SR,[tv:SR1,np:SR2])}.
% sbar([parse:sbar(WHNP,IV),depth:0,sel:K]) -->
%     whnp_sbj([parse:WHNP,sel:K]),
%     iv([parse:IV,sel:K]).
sbar([parse:sbar(WHNP,NP,TV),sem:SR,depth:D,sel:K]) -->
    whnp_obj([parse:WHNP,sel:K]),
    np_sbj([parse:NP,sem:SR1,depth:D,sel:K]),
    tv([parse:TV,sem:SR2,sel:K]),
    {combine(sbar:SR,[np:SR1,tv:SR2])}.
sbar([parse:sbar(NP,TV),sem:SR,depth:D,sel:K]) -->
    np_sbj([parse:NP,sem:SR1,depth:D,sel:K]),
    tv([parse:TV,sem:SR2,sel:K]),
    {combine(sbar:SR,[np:SR1,tv:SR2])}.

/* ==============================
   Lexicon
============================== */

% Noun
n([parse:n(Surf),sem:SR,num:Num,sel:K]) -->
    {lex(n,[surf:Surf,num:Num])},
    Surf,
    {semlex(n,[symbol:Surf,sem:SR])},
    {selector(K)}.

n([parse:n(ADJ,Surf),sem:SR,num:Num,sel:K]) -->
    adj([parse:ADJ,sem:SR1]),
    {lex(n,[surf:Surf,num:Num])},
    Surf,
    {semlex(n,[symbol:Surf,sem:SR2])},
    {combine(n:SR,[adj:SR1,n:SR2])},
    {selector(K)}.

n([parse:n(Surf,PP),sem:SR,num:Num,sel:K]) -->
    {lex(n,[surf:Surf,num:Num])},
    Surf,
    {semlex(n,[symbol:Surf,sem:SR1])},
    pp([parse:PP,sem:SR2]),
    {combine(n:SR,[n:SR1,pp:SR2])},
    {selector(K)}.

n([parse:n(Surf,RC),sem:SR,num:Num,sel:K]) -->
    {lex(n,[surf:Surf,num:Num])},
    Surf,
    {semlex(n,[symbol:Surf,sem:SR1])},
    rc([parse:RC,sem:SR2]),
    {combine(n:SR,[n:SR1,rc:SR2])},
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
det([parse:det(Surf),sem:SR,num:Num,sel:_]) -->
    {lex(det,[surf:Surf,num:Num])},
    Surf,
    {semlex(det,[symbol:Surf,sem:SR])}.

% Intransitive Verb
iv([parse:iv(Surf),sem:SR,sel:K]) -->
    {lex(iv,[surf:Surf])},
    Surf,
    {semlex(iv,[symbol:Surf,sem:SR])},
    {selector(K)}.

iv([parse:iv(Surf,ADV),sem:SR,sel:K]) -->
    {lex(iv,[surf:Surf])},
    Surf,
    adv([parse:ADV,sem:SR2]),
    {semlex(iv,[symbol:Surf,sem:SR1])},
    {combine(iv:SR,[iv:SR1,adv:SR2])},
    {selector(K)}.

iv([parse:iv(Surf,PP),sem:SR,sel:K]) -->
    {lex(iv,[surf:Surf])},
    Surf,
    {semlex(iv,[symbol:Surf,sem:SR1])},
    pp([parse:PP,sem:SR2]),
    {combine(iv:SR,[iv:SR1,pp:SR2])},
    {selector(K)}.

iv([parse:iv(Surf,CONJ),sem:SR,sel:K]) -->
    {lex(iv,[surf:Surf])},
    Surf,
    conj([parse:CONJ,sem:SR2]),
    {semlex(iv,[symbol:Surf,sem:SR1])},
    {combine(iv:SR,[iv:SR1,conj:SR2])},
    {selector(K)}.

iv([parse:iv(Surf,DISJ),sem:SR,sel:K]) -->
    {lex(iv,[surf:Surf])},
    Surf,
    disj([parse:DISJ,sem:SR2]),
    {semlex(iv,[symbol:Surf,sem:SR1])},
    {combine(iv:SR,[iv:SR1,disj:SR2])},
    {selector(K)}.


% Transitive Verb
tv([parse:tv(Surf),sem:SR,sel:K]) -->
    {lex(tv,[surf:Surf])},
    Surf,
    {semlex(tv,[symbol:Surf,sem:SR])},
    {selector(K)}.

% Adjectives
adj([parse:adj(Surf),sem:SR]) -->
    {lex(adj,[surf:Surf])},
    Surf,
    {semlex(adj,[symbol:Surf,sem:SR])}.

% Adverbs
adv([parse:adv(Surf),sem:SR]) -->
    {lex(adv,[surf:Surf])},
    Surf,
    {semlex(adv,[symbol:Surf,sem:SR])}.

% Preposition
pp([parse:pp(Surf),sem:SR]) -->
    {lex(pp,[surf:Surf])},
    Surf,
    {semlex(pp,[symbol:Surf,sem:SR])}.

% Relative Clause
rc([parse:rc(which,Surf),sem:SR]) -->
    {lex(rc,[surf:Surf])},
    [which],
    Surf,
    {semlex(rc,[symbol:Surf,sem:SR])}.

rc([parse:rc(that,Surf),sem:SR]) -->
    {lex(rc,[surf:Surf])},
    [that],
    Surf,
    {semlex(rc,[symbol:Surf,sem:SR])}.

% Disjunction
disj([parse:disj(Surf),sem:SR]) -->
    {lex(disj,[surf:Surf])},
    [or],
    Surf,
    {semlex(disj,[symbol:Surf,sem:SR])}.

% Conjunction
conj([parse:conj(Surf),sem:SR]) -->
    {lex(conj,[surf:Surf])},
    [and],
    Surf,
    {semlex(conj,[symbol:Surf,sem:SR])}.

% Punctuation
punct([parse:punct(Surf),sem:SR]) -->
    {lex(punct,[surf:Surf])},
    {semlex(punct,[symbol:Surf,sem:SR])},
    Surf.

/* ==============================
  Lexical Entries
============================== */

% Noun
lex(n,[surf:[dog],num:sing]).
lex(n,[surf:[dogs],num:plur]).

lex(n,[surf:[rabbit],num:sing]).
lex(n,[surf:[rabbits],num:plur]).

lex(n,[surf:[lion],num:sing]).
lex(n,[surf:[lions],num:plur]).

lex(n,[surf:[cat],num:sing]).
lex(n,[surf:[cats],num:plur]).

lex(n,[surf:[bear],num:sing]).
lex(n,[surf:[bears],num:plur]).

lex(n,[surf:[tiger],num:sing]).
lex(n,[surf:[tigers],num:plur]).

lex(n,[surf:[elephant],num:sing]).
lex(n,[surf:[elephants],num:plur]).

lex(n,[surf:[fox],num:sing]).
lex(n,[surf:[foxes],num:plur]).

lex(n,[surf:[monkey],num:sing]).
lex(n,[surf:[monkeys],num:plur]).

lex(n,[surf:[wolf],num:sing]).
lex(n,[surf:[wolves],num:plur]).

lex(n,[surf:[bird],num:sing]).
lex(n,[surf:[birds],num:plur]).

lex(n,[surf:[horse],num:sing]).
lex(n,[surf:[horses],num:plur]).

lex(n,[surf:[giraffe],num:sing]).
lex(n,[surf:[giraffes],num:plur]).

% lexical replacement target

lex(n,[surf:[animal],num:sing]).
lex(n,[surf:[animals],num:plur]).

lex(n,[surf:[creature],num:sing]).
lex(n,[surf:[creatures],num:plur]).

lex(n,[surf:[mammal],num:sing]).
lex(n,[surf:[mammals],num:plur]).

lex(n,[surf:[beast],num:sing]).
lex(n,[surf:[beasts],num:plur]).


% WH-NP
lex(whnp_sbj,[surf:[that]]).
lex(whnp_sbj,[surf:[which]]).
lex(whnp_obj,[surf:[that]]).
lex(whnp_obj,[surf:[which]]).

lex(det,[surf:[emptydet],num:plur]).
lex(det,[surf:[no],num:sing]).
lex(det,[surf:[some],num:sing]).
lex(det,[surf:[few],num:plur]).
lex(det,[surf:[a,few],num:plur]).
lex(det,[surf:[at,least,three],num:plur]).
lex(det,[surf:[less,than,three],num:plur]).
lex(det,[surf:[more,than,three],num:plur]).
lex(det,[surf:[at,most,three],num:plur]).
lex(det,[surf:[every],num:sing]).
lex(det,[surf:[each],num:sing]).
lex(det,[surf:[all],num:plur]).

lex(iv,[surf:[ran]]).
lex(iv,[surf:[walked]]).
lex(iv,[surf:[came]]).
lex(iv,[surf:[waltzed]]).
lex(iv,[surf:[swam]]).
lex(iv,[surf:[rushed]]).
lex(iv,[surf:[danced]]).
lex(iv,[surf:[dawdled]]).
lex(iv,[surf:[escaped]]).
lex(iv,[surf:[left]]).
lex(iv,[surf:[cried]]).
lex(iv,[surf:[slept]]).

lex(iv,[surf:[moved]]).
lex(iv,[surf:[worked]]).
lex(iv,[surf:[existed]]).
lex(iv,[surf:[changed]]).

lex(tv,[surf:[kissed]]).
lex(tv,[surf:[kicked]]).
lex(tv,[surf:[hit]]).
lex(tv,[surf:[cleaned]]).
lex(tv,[surf:[touched]]).
lex(tv,[surf:[loved]]).
lex(tv,[surf:[accepted]]).
lex(tv,[surf:[hurt]]).
lex(tv,[surf:[licked]]).
lex(tv,[surf:[followed]]).

% adj_list = ["small","large","crazy","polite","wild"]
lex(adj,[surf:[small]]).
lex(adj,[surf:[large]]).
lex(adj,[surf:[crazy]]).
lex(adj,[surf:[polite]]).
lex(adj,[surf:[wild]]).
lex(adj,[surf:[red]]).
lex(adj,[surf:[blue]]).
lex(adj,[surf:[green]]).

% adv_list = ["slowly","quickly","seriously","suddenly","lazily"]
lex(adv,[surf:[slowly]]).
lex(adv,[surf:[quickly]]).
lex(adv,[surf:[seriously]]).
lex(adv,[surf:[suddenly]]).
lex(adv,[surf:[lazily]]).

% pp_list = ["in the area","on the ground","at the park","near the shore","around the island"]
lex(pp,[surf:[in,the,area]]).
lex(pp,[surf:[on,the,ground]]).
lex(pp,[surf:[at,the,park]]).
lex(pp,[surf:[near,the,shore]]).
lex(pp,[surf:[around,the,island]]).

% rc_list = ["which ate dinner","that liked flowers","which hated the sun","that stayed up late"]
lex(rc,[surf:[ate,dinner]]).
lex(rc,[surf:[liked,flowers]]).
lex(rc,[surf:[hated,the,sun]]).
lex(rc,[surf:[stayed,up,late]]).

lex(rc,[surf:[ate,flogs]]).
lex(rc,[surf:[held,a,stick]]).

% disj_list = ["or laughed","or groaned","or roared","or screamed","or cried"]
lex(disj,[surf:[laughed]]).
lex(disj,[surf:[groaned]]).
lex(disj,[surf:[roared]]).
lex(disj,[surf:[screamed]]).
lex(disj,[surf:[cried]]).

lex(disj,[surf:[flied]]).
lex(disj,[surf:[talked]]).


% conj_list = ["and laughed","and groaned","and roared","and screamed","and cried"]
lex(conj,[surf:[laughed]]).
lex(conj,[surf:[groaned]]).
lex(conj,[surf:[roared]]).
lex(conj,[surf:[screamed]]).
lex(conj,[surf:[cried]]).

lex(conj,[surf:[flied]]).
lex(conj,[surf:[talked]]).


lex(punct,[surf:[[,]]]).


/* ==============================
  Semantic Composition
============================== */

% combine(sinv:app(B,app(A,C)),[av:A,np:B,vp:C]).
combine(s:S,[np:NP,iv:IV]) :-
    S = app(NP,IV).
combine(np:NP,[det:Det,n:N]) :-
    NP = app(Det,N).
combine(np:NP,[det:Det,n:N,sbar:Sbar]) :-
    NP = app(Det,lam(X,and(app(N,X),app(Sbar,X)))).

combine(sbar:Sbar,[tv:TV,np:NP]) :-
    Sbar = lam(X,app(NP,lam(Y,app(app(TV,Y),X)))).

combine(sbar:Sbar,[np:NP,tv:TV]) :-
    Sbar = lam(Y,app(NP,lam(X,app(app(TV,Y),X)))).

combine(n:SR,[adj:ADJ,n:N]) :-
    SR = lam(X,and(app(ADJ,X),app(N,X))).

combine(iv:SR,[iv:IV,adv:ADV]) :-
    SR = lam(X,and(app(IV,X),app(ADV,X))).

combine(n:SR,[n:N,pp:PP]) :-
    SR = lam(X,and(app(N,X),app(PP,X))).

combine(iv:SR,[iv:IV,pp:PP]) :-
    SR = lam(X,and(app(IV,X),app(PP,X))).

combine(n:SR,[n:N,rc:RC]) :-
    SR = lam(X,and(app(N,X),app(RC,X))).

combine(iv:SR,[iv:IV,disj:Disj]) :-
    SR = lam(X,or(app(IV,X),app(Disj,X))).

combine(iv:SR,[iv:IV,conj:Conj]) :-
    SR = lam(X,and(app(IV,X),app(Conj,X))).


/* ==============================
  Semantic Lexicon
============================== */

semlex(n,[symbol:[Surf],sem:SR]) :-
    % write(Surf),nl,
    singl(Surf,N),
    % compose(F,Surf,[X]),
    % write(Surf),nl,
    compose(F,N,[X]),
    SR = lam(X,F).
semlex(iv,[symbol:[Surf],sem:SR]) :-
    SR = lam(X,F),
    compose(F,Surf,[X]).
semlex(tv,[symbol:[Surf],sem:SR]) :-
    SR = lam(Y,lam(X,F)),
    compose(F,Surf,[X,Y]).
semlex(punct,[symbol:_,sem:SR]) :-
    SR = lam(X,X).

semlex(det,[symbol:[emptydet],sem:SR]) :-
    SR = lam(F,lam(G,some(X,and(app(F,X),app(G,X))))).

semlex(det,[symbol:[no],sem:SR]) :-
    SR = lam(F,lam(G,not(some(X,and(app(F,X),app(G,X)))))).

semlex(det,[symbol:[some],sem:SR]) :-
    SR = lam(F,lam(G,some(X,and(app(F,X),app(G,X))))).

semlex(det,[symbol:[a,few],sem:SR]) :-
    SR = lam(F,lam(G,some(X,and(few(X),and(app(F,X),app(G,X)))))).

semlex(det,[symbol:[few],sem:SR]) :-
    SR = lam(F,lam(G,not(some(X,and(few(X),and(app(F,X),app(G,X))))))).

semlex(det,[symbol:[at,least,three],sem:SR]) :-
    SR = lam(F,lam(G,some(X,and(atleastthree(X),and(app(F,X),app(G,X)))))).

semlex(det,[symbol:[less,than,three],sem:SR]) :-
    SR = lam(F,lam(G,not(some(X,and(lessthanthree(X),and(app(F,X),app(G,X))))))).

semlex(det,[symbol:[more,than,three],sem:SR]) :-
    SR = lam(F,lam(G,some(X,and(morethanthree(X),and(app(F,X),app(G,X)))))).

semlex(det,[symbol:[at,most,three],sem:SR]) :-
    SR = lam(F,lam(G,not(some(X,and(atmostthree(X),and(app(F,X),app(G,X))))))).

semlex(det,[symbol:[every],sem:SR]) :-
    SR = lam(F,lam(G,all(X,imp(app(F,X),app(G,X))))).

semlex(det,[symbol:[each],sem:SR]) :-
    SR = lam(F,lam(G,all(X,imp(app(F,X),app(G,X))))).

semlex(det,[symbol:[all],sem:SR]) :-
    SR = lam(F,lam(G,all(X,imp(app(F,X),app(G,X))))).

semlex(adj,[symbol:[Surf],sem:SR]) :-
    SR = lam(X,F),
    compose(F,Surf,[X]).

semlex(adv,[symbol:[Surf],sem:SR]) :-
    SR = lam(X,F),
    compose(F,Surf,[X]).

semlex(pp,[symbol:Surf,sem:SR]) :-
    SR = lam(X,F),
    atomics_to_string(Surf,Str),
    atom_string(P,Str),
    compose(F,P,[X]).

semlex(rc,[symbol:Surf,sem:SR]) :-
    SR = lam(X,F),
    atomics_to_string(Surf,Str),
    atom_string(P,Str),
    compose(F,P,[X]).

semlex(disj,[symbol:[Surf],sem:SR]) :-
    SR = lam(X,F),
    compose(F,Surf,[X]).

semlex(conj,[symbol:[Surf],sem:SR]) :-
    SR = lam(X,F),
    compose(F,Surf,[X]).

singl(dog,dog).
singl(dogs,dog).
singl(rabbit,rabbit).
singl(rabbits,rabbit).
singl(lion,lion).
singl(lions,lion).
singl(cat,cat).
singl(cats,cat).
singl(bear,bear).
singl(bears,bear).
singl(tiger,tiger).
singl(tigers,tiger).
singl(elephant,elephant).
singl(elephants,elephant).
singl(fox,fox).
singl(foxes,fox).
singl(monkey,monkey).
singl(monkeys,monkey).
singl(wolf,wolf).
singl(wolves,wolf).
singl(bird,bird).
singl(birds,bird).
singl(horse,horse).
singl(horses,horse).

singl(animal,animal).
singl(animals,animal).
singl(creature,creature).
singl(creatures,creature).
singl(mammal,mammal).
singl(mammals,mammal).
singl(beast,beast).
singl(beasts,beast).
singl(giraffe,giraffe).
singl(giraffes,giraffe).

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

compose(Term,Symbol,ArgList):-
    Term =.. [Symbol|ArgList].

nicePrint(SR):-
   \+ \+ (numbervars(SR,0,_), print(SR)).


/* ==============================
   Main Predicates
============================== */

% Generate a plain sentence with depth N
plain(N,K) :-
   s([parse:_,sem:_,depth:N,cond:_,sel:K],Sentence,[]),
   yield(Sentence),nl,
   fail.

% Generate a parse tree with depth N
gen(N,K) :-
   s([parse:Tree,sem:_,depth:N,cond:_,sel:K],_,[]),
   ptb(Tree),nl,
   fail.

% parsing
parse(D,S) :-
   s([parse:Parse,sem:_,depth:D,cond:_,sel:1],S,[]),
   write(Parse),nl.

% semantic parsing
semparse(D,S) :-
   s([parse:_,sem:SR,depth:D,cond:_,sel:1],S,[]),
   betaConvert(SR,NF),
   % nicePrint(NF),
   fol2tptp(NF,user).

% semantic parsing niceprint
semparseniceprint(D,S) :-
   s([parse:_,sem:SR,depth:D,cond:_,sel:1],S,[]),
   betaConvert(SR,NF),
   nicePrint(NF).
