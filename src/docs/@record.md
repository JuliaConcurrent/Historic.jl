    @record($name, $k₁ = $v₁, …, $kₙ = $vₙ)
    @record($name, $k₁ = $v₁, …, $kₙ = $vₙ, {$a₁ = $b₁, …, $aₙ = $bₙ})

Record event named `$name` and optional event data (key-value pairs `$kᵢ = $vᵢ`)
with optional control arguments `$aᵢ = $bᵢ`.

# Extended help

## Examples

* `@record(:n1)` records an event named `:n1`.
* `@record(:n2, k1 = 0)` records an event named `:n2` with optional data key
  `k1` and value `0`.
* `@record(rand(Bool) ? :n3 : :n4)` records either an event named `:n3` or an
  event named `:n4`.
* `@record(:n5, {log = nothing})` records an event without logging it.

## Arguments

The first argument `$name` is an expression evaluates to a `Symbol`.

If the last argument is wrapped in a pair of `{` and `}`, it is treated as
a set of control argument (see below).

The rest of the arguments are optional. Each of these argument is either an
assignment of form `$k = $v` or a variable name `$k`. The latter is equivalent
to `$k = $k`.

### Optional control argument

If the last argument is of form `{$a₁ = $b₁, …, $aₙ = $bₙ}`, each assignment
expression `$a = $b` specifies a (non-data) control option.

* `log` (`$b::Union{Nothing,NamedTuple}`): Options to the logger.
  `log = nothing` disables logging.
* `yield` (`$b::Bool`): Passing `yield = false` tries to avoid code paths
  that may yield to the scheduler.
