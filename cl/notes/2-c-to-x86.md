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
    - Usually put into registers in x86, until we run out of registers
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

Another example:
```c
long f(long x, long y) {
  long a, b;
  a = x + 42;
  b = y + 23;
  return a * b;
}
```
```asm
f:
pushq %rbp
movq %rsp %rbp
addq $16 %rsp ; not necessary, leaf function!
movq %rdi -8(%rbp)
addq $42 -8(%rbp)
movq %rsi -16(%rbp)
addq $23 -16(%rbp)
movq -8(%rbp) %rax
mulq -16(%rbp) %rax
subq $16 %rbp
popq %rbp
ret
```

- To call function pointers, use `callq *-8(%rbp)`

# Security
- Can manipulate the stack to write arbitrary data into it
- e.g. passing a pointer to an array, but writing to that array beyond the
  allocated length for it
- Can even overwrite the return address
  - Modern compilers have stack canaries which has values on the stack next to
    the return addresses
  - When attacker overwrites the return address, they also overwrite the stack
    canary
  - If the canary value is changed, then execution of the program is stopped
  - TODO: What checks the canary value?

# Optimisations
- Constant propagation
  - e.g. `const int x = 1`, further occurrences of `x` will be replaced with
    `$42`
- Compile time evaluation
  - e.g. `x = 1 + 2` becomes `x = 3` 
- Dead code elimination
  - If code can't be reached, don't compile it and throw warning

## Leaf Functions
- Function that makes no calls to other functions
- Simpler to compile than normal functions
- No need to adjust stack pointer
- No need to save registers onto stack (TODO: why?)

## Function Inlining
- Essentially do the function call at compile time
- Then we don't have the run time overhead
- Simple as bringing the code from the callee into the caller

## Tail Calls
- Tail position: the last thing that happens in a function before it returns
  - `return f(x);` → `f` is in the tail position
  - `return 1 + f(x);` → `f` is **not** in the tail position
  - `return f(x) + 1;` → `f` is **not** in the tail position
- When a function is in the tail position, it is a tail call, and we can
  optimise it
- We do this by doing a `jmp` rather than a `call` to the function
- Is `return (*g)();` a tail call?
  - Yes, we dereference then call `*g` so the call is the last thing that
    happens
- Is `return *g();` a tail call?
  - No, we call `g` then dereference the return, the dereferencing is the last
    thing that happens

# Structure Member Access
- We access by offset
- If pointer to a struct is in `%rdi`, we can access it's first element with
  `(%rdi)`, and its second with `-8(%rdi)` (dependent on element size)
- If no pointer, the struct is just placed, element by element, on the stack
- Struct definitions don't add to compiled code, just the compiler's symbol
  look up, used for generating struct accesses
- Passing structs to functions means their put on the stack, not registers

How does this get compiled?
```c
struct S {
  struct S *prev;
  struct S *next;
  long data;
};

int main() {
  // ...
  p->data = 12345;
  p->next = p->prev->next;
  // ...
}
```

```asm
; assume `p` is in `%rsi`

; `p->data = 12345;`
movq $12345 -16(%rsi) ; `-16` to access 3rd element in `S`

; `p->next = p->prev->next;`
movq -8(%rsi) %rdi ; put `p->prev` into `%rdi`
movq (%rdi) (%rsi) ; put the `next` of `%rdi` into the `next` of `%rsi`
```
TODO: Get this checked

## Union
- Union elements all have the same address
- What changes is how they are accessed/used

## OOP
- The `this` pointer is a variable that's passed to member functions
- Can rewrite all objects into functions that take `this` pointer
- LLVM has no concept of OOP

