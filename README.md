# FilterFormatter

This is a `mix format`
[plugin](https://hexdocs.pm/mix/main/Mix.Tasks.Format.html#module-plugins)
which filters user-configurable sigils and files by piping their contents to a
given command line program.

The program is expected to read input via stdin and produce formatter output on
stdout. An exit code of 0 is considered success, any other exit code is
considered failure.

This makes it easy to hook any command line tool into `mix format`.

## Installation

First, add `filter_formatter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:filter_formatter, "~> 0.1.0"}
  ]
end
```

Next, fetch dependencies. This will also pull in
[Rambo](https://hex.pm/packages/rambo) since that's what this plugin uses for
running external programs. To make sure that Rambo works, run `mix
compile.rambo` once to build any required intermediate binaries.

```sh
mix deps.get && mix compile.rambo
```

Finally, add `FilterFormatter` to your `.formatter.exs` file and configure the
`filter_formatter` option such that it associates sigils and/or file extensions
with commands to execute:

```elixir
[
  inputs: ["*.{ex,exs,heex}", "priv/*/seeds.exs", ...],
  plugins: [FilterFormatter],
  filter_formatter: [
      ...
  ]
]
```

## Example: filtering SQL via SQLFluff

This specification which makes `mix format` pass the contents of the `SQL`
sigil as well as the code in any `.sql` files through
[SQLFluff](https://sqlfluff.com/):

```elixir
[
  plugins: [FilterFormatter],
  filter_formatter: [
    [
      extensions: ["*.sql"],
      sigils: [:SQL],
      executable: "sqlformat",
      args: ["format", "-", "--dialect", "postgres", "--nocolor", "--disable-progress-bar"]
    ]
  ]
]
```

Please see the [API documentation](https://hexdocs.pm/filter_formatter) for
more information.
