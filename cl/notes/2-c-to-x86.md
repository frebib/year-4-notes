# x86 Syntax

- `mov x y` moves `x` into `y`
- `r` prefix on register means 64 bit
- `%` means register
- `$` means constant
- `%rbp` and `%rsp`
  - Base pointer and stack pointer
  - Base pointer points to the beginning of the stack for the current call frame
  - Stack pointer points to the end of the stack that we have currently used
  - On a function call:
    - `%rbp` is pushed onto stack, preserving it for when callee returns
    - `%rbp` <- `%rsp` so that the callee has an unused call frame

# How the Stack Looks

- We draw the stack growing downwards
- The stack pointer decreases as we add things to it
- Each frame includes:
  - Parameters for function
  - Return address for function
  - Automatic (local) variables

# Function Example

```c
void f(long x, long *p) {
  *p = x;
}

long g() {
  long a = 42;
  f(a + 1, &a);
  return a;
}
```
...gets translated to...
```asm
g:
; prelude
pushq %rbp
movq %rsp, %rbp
; make space in stack for automatic (local) variables
subq $16, %rsp
; move the location of `a` into `%rsi`
leaq -8(%rbp), %rsi
; set `a = 42`
movq $42, -8(%rbp)
; move `a` into `%rax`, and add 1
movq -8(%rbp), %rax
addq $1, %rax
; move `%rax` (`a + 1`) into `%rdi` for function call
movq %rax, %rdi
; call `f`
callq f
; move `a` into return register
movq -8(%rbp), %rax
; undo the subtraction at the beginning of the function call to reset the
; stack pointer
addq $16, %rsp
; epilogue
popq %rbp
ret

; `f` unoptimized:
f:
; prelude
pushq %rbp
movq %rsp, %rbp
; move parameters from registers onto stack
movq %rdi, -8(%rbp)
movq %rsi, -16(%rbp)
; move back into registers in reverse order (???)
; this could just be inefficient, loading onto stack to get params, then
; back into registers for computation
movq -8(%rbp), %rsi
movq -16(%rbp), %rdi
; move `%rsi` into what `%rdi` points to, aka set parameter `p` to hold `x`
movq %rsi, (%rdi)
; epilogue
popq %rbp
ret

; `f` optimized:
f:
; conducts the move directly in the registers passed to the function
movq %rdi, (%rsi)
ret
```

# Optimisations

## Function Inlining

- Essentially do the function call at compile time
- Then we don't have the run time overhead
- Simple as bringing the code from the callee into the caller

## Tail Calls

- Tail position: the last thing that happens in a function before it returns
  - `return f(x);` → `f` is in the tail position
  - `return 1 + f(x);` → `f` is **not** in the tail position
  - `return f(x) + 1;` → `f` is **not** in the tail position
- When a function is in the tail position, it is a tail call, and we can optimise it
- We do this by doing a `jmp` rather than a `call` to the function
- Is `return (*g)();` a tail call?
  - Yes, we dereference then call `*g` so the call is the last thing that happens
- Is `return *g();` a tail call?
  - No, we call `g` then dereference the return, the dereferencing is the last thing that happens

# Structure Member Access

- We access by offset
- If pointer to a struct is in `%rdi`, we can access it's first element with `(%rdi)`, and its second with `-8(%rdi)`.
- What if we don't have a pointer, but the struct itself?
  - TODO: ask about this

## OOP

TODO: write section

