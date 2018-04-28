# Computer Aided Verification

# Syllabus
- Modelling sequential and parallel systems
  - Labeled transition systems (LTS)
  - Parallel computation
- Temporal logic
  - LTL, CTL, CTL\*
- Model checking
  - CTL model checking algorithms
  - Automata-theoretic model checking (LTL)
- Verification tools (SPIN)
  - Not on exam
- Advanced verification techniques
  - Bounded model checking

# Labeled Transition Systems (LTSs))
- A tuple `(S, Act, →, I, AP, L)` where
  - `S` is a set of states
  - `Act` is a set of actions
  - `→ ⊆ S x Act x S` is a transition relation
    - Given a state, if we perform this action, what state do we end up in?
  - `I ⊆ S` is a set of initial states
  - `AP` is a set of atomic propositions
    - Possible labels for a state
  - `L : S → 2^AP` is a labelling function
    - Given a state, what labels are active for it?
- A LTS is finite iff  `S`, `Act`, and `AP` are finite
- This module mostly assumes finite LTSs

## Transitions
- `s -α-> s'` iff `(s, α, s) ∈ →`
- Direct successors:
  - `Post(s, α) = {s' ∈ S | s -α-> s'}`
  - `Post(s) = union(Post(a, α) for α in Act)`
- Direct predecessors:
  - `Pre(s, α) = {s' ∈ S | s' -α-> s}`
  - `Pre(s) = union(Pre(a, α) for α in Act)`
- Terminal states
  - `s ∈ S` is terminal iff `Post(s) = ø`
  - This means no outgoing transitions

## Paths
- Sequence of alternating states and actions
  - i.e. `s₀α₀s₁α₁s₂α₂...` such that `sᵢ -αᵢ-> sᵢ₋₁`
- A finite path is a finite prefix of an infinite path
- Reachability
  - `s' ∈ S` is reachable from `s ∈ S` iff there is a finite path from `s`
    to `s'`
  - `s ∈ S` is a reachable state iff it is reachable from some `s₀ ∈ I`

