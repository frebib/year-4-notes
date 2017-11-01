# Introduction

## Context-Free Grammar

Consists of

1) Terminal symbols (letters in the language) (`a`, `b`, ... `+`)

2) Non-terminal symbols (`A`, `B`, `S`...)

3) A distinguished start symbol `S`

4) Rules of the form `A -> X_1 ... X_n`


## Notation

- Single symbols

  - `a`, `b`, `c`... for terminals

  - `A`, `B`, `C`... for non-terminals

    - `S` for the start symbol

  - `X-Z` for terminals/non-terminals

- Strings of symbols

  - `v-z` for strings of terminals

  - `α`, `β`, `γ`... for strings of terminals/non-terminals

    - `ε` for the empty string

## Derivations

Derivation step: `βAγ => βαγ` if there is a rule `A -> α`

Leftmost derivation step: `wAγ =>l wαγ` 

Rightmost derivation step: `βAz =>r βαz` 

## Dyck Language Grammar Example

Contains all well bracketed sentences, e.g. [[()[]]] but not [(])

Rules:
1) `D -> [D]D`

2) `D -> (D)D`

3) `D -> ε`

## Ambiguity

- A grammar is ambiguous if there is more than one possible parse tree for a sentence

- Ambiguity != Non-determinism

## Definition of a Parser

Given a grammar and some string `w`:

- If `w` is in the language of the grammar, parser provides a derivation

- If `w` is not in the language of the grammar, parser rejects it

- Parser always terminates


# LL and LR Parsers
## LL Parser

### State

`<π, w>` where `π` is the stack of predictions, and `w` is the remaining terminal input symbols

### Rules

1) Predict: `<Aπ, w> -> <απ, w>` iff `A -> α`. If we can apply a rule on the head of the stack, apply it

2) Match: `<aπ, aw> -> <π, w>`. If the prediction on the stack matches the input, we have a successful parse and can remove it from the state

3) Start with state `<S, w>` where `w` is the complete input

4) Accept on `<ε, ε>`, when all predictions are gone and there is no more input

5) We fail on either `<ε, w>` or `<π, ε>`

### Example

Given the rules:
```
S -> Lb
L -> aL
L -> ε
```

Parse `aab`:
```
<S, aab>
predict -> <Lb, aab>
predict -> <aLb, aab>
match   -> <Lb, ab>
predict -> <aLb, ab>
match   -> <Lb, b>
predict -> <b, b>
match   -> <ε, ε> // reached accepting state!
```

Parse `ba`:
```
<S, ba>
predict -> <Lb, ba>
predict -> <b, ba>
match   -> <ε, a> // can't perform predict or match, so the input isn't accepted
```

## LR Parser

### State

`<π, w>` where `π` is the stack of reduced input, and `w` is the remaining terminal input symbols

### Rules

1) Shift: `<ρ, aw> -> <ρa, w>`. Move a terminal from the input into the stack

2) Reduce: `<ρα, w> -> <ρA, w>` iff `A -> α`. If we have seen the output from a rule, we can reduce it to the rule's non-terminal lsymbol.

3) Start with `<ε, w>`, so that we can start shifting onto the empty stack to eventually reduce

4) Accept on `<S, ε>`, when there's no input left and we've reduced all seen input to the start state

### Example

Given the rules:
```
S -> A
S -> B
D -> a
A -> ab
B -> ac
```

Parse `ab`:
```
<ε, ab>
shift  -> <a, b>
shift  -> <ab, ε>
reduce -> <A, ε>
reduce -> <S, ε> // reached accepting state!
```

