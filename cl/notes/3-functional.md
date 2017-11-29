# Lambda Calculus

## Syntax

```
M ::= x
    | MM
    | λx.M
    | N

N ::= 1 | 2 | 3 | ...
```

We don't need `N` for lambda calculus, but it makes it easier to understand

## Free Variables

- Variables that have no value
- `z(x y)`: `z`, `x`, `y` are free
- `λx.x`: none are free
- `λx.y x`: `y` is free
- `λy.λx.y x`: none are free
- `(λy.λx.y x) x`: `x` is free
- `(λx.x)(λy.x) y`: `y` and second `x` are free

## Substitution

- `M₁[x |-> M₂]`
  - Set `x` to `M₂` in the context of `M₁`
- For example, `(y x)[x |-> 5]` becomes (y 5)

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
- Not efficient. Copying the entirety of a value into all references will not be quick

## Lambda Calculus Examples

TODO: Add parts about loops, pairs, etc.

# CEK Machine

## CEK Components

- `C` stands for code (or control)
  - The expression the machine is currently trying to evaluate
- `E` stands for environment
  - Holds the bindings of free variabels in `C`
- `K` stands for continuation
  - Holds what the machine to do once finished with `C`

## Closure

A value `W` is defined as:
```
W ::= n
    | clos(λx.M, E)
```
Where `n` is a constant, and `clos(...)` is a closure including `x`, `M`, and `E`.

## Environment

The environment is a a list of values:
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
1) Evaluate `M₁` getting `W₁`, pushing the frame `(○ M₂ E)` so we can later evalute M₂
2) Evaluate `M₂` (popped from stack) getting `W₂`, and push the frame `(W₁ ○)` to the stack

## CEK Rules

```
<x | E | K> → <lookup x in E | E | K>
```
If we have a variable `x`, we must look it up in `E` and set the value to be the current code

```
<M₁M₂ | E | K> → <M₁ | E | (○ M₂ E), K>
```
If we have an application of `M₁M₂`, we
1) Set the current code to `M₂`
2) Push onto the continuation `M₂` along with the current environment `E`

```
<λx.M | E | K> → <clos(λx.M, E) | E | K>
```
If we have a lambda expression, close it with the current environment

```
<W | E₁ | (○ M E₂), K> → <M | E₂ | (W ○), K>
```
TODO: Last two rules

```
<W | E₁ | (clos(λx.M, E₂) ○), K> → <M | E₂[x |-> W] | K>
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

