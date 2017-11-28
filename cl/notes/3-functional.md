# Lambda Calculus

## Syntax

```
M ::= x
    | MM
    | λx.M
    | N

N :== 1 | 2 | 3 | ...
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

