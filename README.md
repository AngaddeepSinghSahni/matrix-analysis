# Matrix Explorer

A tool that takes a matrix and tells you everything about it, with all the core maths written in **Haskell** using exact fractions (`Rational`), so there are no rounding errors.

> **Status: work in progress.** The core linear algebra (Tier 1) is done and working in the terminal. The website, tests and more advanced features are planned and listed below.

I'm a first-year Maths & Computer Science student at the University of Bristol, building this to learn Haskell properly and to apply what I'm learning in linear algebra.

## Why exact arithmetic?

With decimals, `0.1 + 0.2` isn't exactly `0.3`, and rank or independence checks can quietly give wrong answers. Using `Rational` means `1/3` stays `1/3`, so every result is exactly correct.

## What it can do right now (Tier 1)

- Elementary row operations: swap, scale, add a multiple of a row
- **Row echelon form (REF)** and **reduced row echelon form (RREF)**
- Step-by-step log of every row operation, replayed with the matrix after each step
- Pivot positions, **rank** and **nullity** (rank-nullity theorem)
- Whether the **columns** or **rows** are linearly independent
- **Determinant**, computed from the row operations (each swap and scale is tracked)
- **Inverse**, via augmented row-reducing `[A | I]`
- Input validation (rejects ragged or empty matrices)

## Running it

You need [GHC](https://www.haskell.org/ghcup/) installed.

```
ghci RowReduction.hs
```

Then try, for example:

```haskell
rref [[1,2],[3,4]]
determinant [[1,2],[3,4]]
inverse [[1,2],[3,4]]
rank [[1,2,3],[2,4,6]]
```

(Results print as `Rational`s, e.g. `1 % 2` means 1/2. Nicer printing is on the to-do list.)

## Roadmap

### Next up
- [x] Skip logging no-op steps (e.g. scaling a row by 1)
- [ ] `freeColumns`, to explain why columns are dependent
- [ ] Return a clear error (`Either String`) instead of `Nothing` when there is no inverse or determinant
- [ ] A single `Report` type bundling every result, ready to turn into JSON
- [ ] Neat plain-text printing of matrices and fractions

### Tier 2: a more complete picture of a matrix
- [ ] Bases for the column space, row space and null space
- [ ] Left null space
- [ ] Solving `Ax = b`: unique, none, or infinitely many solutions, with the general solution
- [ ] Matrix multiplication, powers, trace
- [ ] LU decomposition (with a permutation matrix if needed)
- [ ] Checks: symmetric, skew-symmetric, diagonal, triangular, orthogonal, idempotent, nilpotent

### Tier 3: stretch goals
- [ ] Characteristic polynomial (exact)
- [ ] Rational eigenvalues, eigenspaces, algebraic vs geometric multiplicity, diagonalizability
- [ ] Gram-Schmidt (orthogonal basis, kept exact)
- [ ] Positive definiteness via leading principal minors
- [ ] Cayley-Hamilton check

### Testing
- [ ] Tests file with hand-written cases
- [ ] QuickCheck property tests for the main theorems:
  - `rref` applied twice changes nothing
  - rank + nullity = number of columns
  - `A × A⁻¹ = I` whenever the inverse exists
  - `det(Aᵀ) = det(A)`
  - rank of `A` equals rank of `Aᵀ`

### Website
- [ ] Small Haskell web server (Scotty) with one endpoint: matrix in, JSON report out
- [ ] Simple page with a matrix input grid
- [ ] Results displayed with proper maths formatting (KaTeX)
- [ ] Highlighted pivot cells in the RREF
- [ ] Step-by-step walkthrough, with the row operation shown next to each matrix
- [ ] Friendly error messages for invalid input
- [ ] Deploy somewhere public

## What I've learned so far

- Recording each row operation as data (a `Step` type) instead of just doing it, so the same log can be replayed, printed and used for the determinant
- Using pairs to carry a result and a log through a recursive function
- Keeping the maths pure and leaving printing and error messages to the outside

## Project layout

```
RowReduction.hs   Elementary Row operations, REF, RREF
MatrixOps.hs      Size validation, Determinant, Inverse, Rank, Nullity
README.md
```
