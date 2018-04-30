# Lambda Calculus

## Syntax
```
M ::= x
    | MM
    | λx.M
    | N

N ::= 1 | 2 | 3 | ...
```

- We don't need `N` for lambda calculus, but it makes it easier to understand
- Left associative, so `M₁M₂M₃` is read as `(M₁M₂)M₃`
- But `λx.xy` is `λx.(xy)`


## Free Variables
- Variables that have no value
- If a lambda expression has no free variables, it is called closed
- `z(x y)`: `z`, `x`, `y` are free
- `λx.x`: none are free
- `λx.y x`: `y` is free
- `λy.λx.y x`: none are free
- `(λy.λx.y x) x`: `x` is free
- `(λx.x)(λy.x) y`: `y` and second `x` are free

## Substitution
- `M₁[x |-> M₂]`
  - Set `x` to `M₂` in the context of `M₁`
- For example, `(y x)[x |-> 5]` becomes `(y 5)`
  - `(x x)[x |-> y]` becomes `(y y)`
  - `(x x)[y |-> x]` becomes `(x x)`
  - `(z y)[y |-> λa.a]` becomes `(z (λa.a))`

## Beta Reduction
Beta reduction is the application of a value to a variable:
```
((λx.M₁)M₂) ->β (M₁[x |-> M₂])
```
For example:
```
(λf.f 5)(λx.x)
  ->β (λx.x) 5
  ->β 5

(λz.(λp.p(p z))(λy.y))2
  ->β (λp.p(p 2))(λy.y)
  ->β (λy.y)((λy.y) 2)
  ->β (λy.y)2
  ->β 2
```

Beta reduction has issues:
- Not deterministic. You can have two possible beta reductions in one go
- Not efficient. Copying the entirety of a value into all references will not
  be quick
This makes it not a practical language.

## Lambda Calculus Examples

### Let
`let x = M₁ in M₂` becomes `(λx.M₂)M₁`

### Loops
`((λx.xx)(λx.xx))` can loop forever - TODO: Is this useful?

### Pairs
- `(M₁, M₂) = λv.v M₁ M₂`
- `fst = λp.p(λx.λy.x)`
- `snd = λp.p(λx.λy.y)`

```
fst (M₁, M₂)
  ->  (λp.p(λx.λy.x)) (λv.v M₁ M₂)
  ->β (λv.v M₁ M₂)(λx.λy.x)
  ->β (λx.λy.x) M₁ M₂
  ->β (λy.M₁) M₂
  ->β M₁
```

# CEK Machine

## CEK Components
- `C` stands for code (or control)
  - The expression the machine is currently trying to evaluate
- `E` stands for environment
  - Holds the bindings of free variables in `C`
- `K` stands for continuation
  - Holds what the machine to do once finished with `C`

## Closure
A value `W` is defined as:
```
W ::= n
    | clos(λx.M, E)
```
Where `n` is a constant, and `clos(...)` is a closure including `x`, `M`, and
`E`.

## Environment

The environment is a list of values:
```
E = {x₁ |-> W₁, x₂ |-> W₂, ...}
E = {} = ∅
```

Adding a binding is written as `E[x |-> W]`

Finding a binding is written as `lookup x in E`

## Continuations
A continuation is a stack of frames. The empty stack is ■.

A frame is:
```
F ::= (W ○)
    | (○ M E)
```
Where:
- `W` is some evaluated value
- `M` is something to evaluate
- `E` is the environment

## Function Calls
To evaluate `M₁M₂`, we need to:
1. Evaluate `M₁` getting `W₁`, pushing the frame `(○ M₂ E)` so we can later
   evaluate M₂
2. Evaluate `M₂` (popped from stack) getting `W₂`, and push the frame `(W₁ ○)`
   to the stack. `W₁` is pushed on to the stack.
3. Apply `W₁` to `W₂`.

## CEK Rules
```
<x | E | K> → <lookup x in E | E | K>
```
If we have a variable `x`, we must look it up in `E` and set the value to be
the current code

```
<M₁M₂ | E | K> → <M₁ | E | (○ M₂ E), K>
```
If we have an application of `M₁M₂`, we
1. Set the current code to `M₁`
2. Push onto the continuation `M₂` along with the current environment `E`

```
<λx.M | E | K> → <clos(λx.M, E) | E | K>
```
If we have a lambda expression, close it with the current environment

```
<W | E₁ | (○ M E₂), K> → <M | E₂ | (W ○), K>
```
If `C` is a constant or closure `W`, and we've got a RHS to process on the
stack, swap the two. This discards the current environment

```
<W | E₁ | (clos(λx.M, E₂) ○), K> → <M | E₂[x |-> W] | K>
```
If `C` is a constant or closure `W`, and we've got a closure to process on the
stack, bind `W` to the closure value

We say `M` evaluates to `W` if:
```
<M | ø | ■> →* <W | E | ■>
```

Examples:
```
<((λx.λy.x) 1) 2 | ∅ | ■>
-> <(λx.λy.x) 1 | ∅ | (○ 2 ∅)>
-> <λx.λy.x | ∅ | (○ 1 ∅), (○ 2 ∅)>
-> <clos(λx.λy.x, E) | ∅ | (○ 1 ∅), (○ 2 ∅)>
-> <1 | ∅ | (clos(λx.λy.x, E) ○), (○ 2 ∅)>
-> <λy.x | {x |-> 1} | (○ 2 ∅)>
-> <clos(λy.x, {x |-> 1}) | {x |-> 1} | (○ 2 ∅)>
-> <2 | ∅ | (clos(λy.x, {x |-> 1}) ○)>
-> <x | {x |-> 1, y |-> 2} | ■>
-> <2 | {x |-> 1, y |-> 2} | ■>
```

```
<(λf.f 2)(λx.x) | ∅ | ■>
-> <λf.f 2 | ∅ | (○ (λx.x) ∅)>
-> <clos(λf.f 2, ∅) | ∅ | (○ (λx.x) ∅)>
-> <λx.x | ∅ | (clos(λf.f 2, ∅) ○)>
-> <f 2 | {f |-> λx.x} | ■>
-> <f | {f |-> λx.x} | (○ 2 {f |-> λx.x})>
-> <λx.x | {f |-> λx.x} | (○ 2 {f |-> λx.x})>
-> <clos(λx.x, {f |-> λx.x}) | {f |-> λx.x} | (○ 2 {f |-> λx.x})>
-> <2 | {f |-> λx.x} | (clos(λx.x, {f |-> λx.x}) ○)>
-> <x | {f |-> λx.x, x |-> 2} | ■>
-> <2 | {f |-> λx.x, x |-> 2} | ■>
```

## Optimisations
- Constant propagation
  - Easier than in imperative languages, as symbols stay constant
- Function inlining still possible
  - `let f = λx.M in ...f V...`
  - Becomes `let f = λx.M in ...M[x |-> V]...`

## Here and Go

The language is now extended:
```
M ::= ...
    | go N
    | here M
```

With an extended stack:
```
F ::= ... | »
```

### New Rules
```
<here M | E | K> → <M | E | », K>
```
If we encounter a `here M`, push a `»` onto the stack

```
<go N | E | K₁, », K₂> → <N | E | K₂>
```
If we encounter a `go N`, go to after the next `»` in the stack. `K₁` and `K₂`
are sequences in the stack, and `K₁` does not contain any `»`

```
<W | E | », K> → <W | E | K>
```
If we encounter a `»` on the stack, ignore it

### Examples

```
<here ((λx.2)(go 5)) | ∅ | ■>
-> <(λx.2)(go 5) | ∅ | »>
-> <λx.2 | ∅ | (○ (go 5) ∅), »>
-> <clos(λx.2, ∅) | ∅ | (○ (go 5) ∅), »>
-> <go 5 | ∅ | (clos(λx.2, ∅) ○), »>
-> <5 | ∅ | ■>
```

## Static Single Assignment
- Every variable is only assigned once
- Equivalent of `let` but in intermediate languages (LLVM-IR)

For example:
```c
// Can't replace `x` with `5` because of modification
x = 5;
x = x + 1;
y = x * 2;

// Change to use `x₁` and `x₂`
x₁ = 5;
x₂ = x₁ + 1;
y = x₂ + 1;

// Allows us to replace `x₁` with `5`
x₂ = 5 + 1;
y = x₂ + 1;
```

## Contextual Equivalence
i.e. Two programs behave the same

`M` can be reduced to `n` - written as `M↓n`:
```
<M | ø | ■> ->* <n | E | ■>
```

A context `C` is a "term with a hole":
```
C ::= ○
    | M C
    | C M
    | λx.C
```

We write `C[M]` for the term we get by plugging `M` into the hole position `○`
in `C`.

`M₁` and `M₂` are contextually equivalent if for all contexts `C` and integers
`n`:
```
C[M₁]↓n iff C[M₂]↓n
```

This means we can replace `M₁` with `M₂` if it is faster (and vice versa).

