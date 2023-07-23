defmodule FilterFormatter do
  @moduledoc """
  Format arbitrary files and sigils through external filter programs.

  This is a `mix format`
  [plugin](https://hexdocs.pm/mix/main/Mix.Tasks.Format.html#module-plugins)
  which filters user-configurable sigils and files by piping their contents to
  a given command line program. The program is expected to read input via stdin
  and produce formatter output on stdout. An exit code of 0 is considered
  success, any other exit code is considered failure.

  ## Setup

  Add it as plugin to your `.formatter.exs` file. Specify sigils/file
  extensions to filter and a command line to use for filtering in a
  `:filter_formatter` option.

  ```elixir
  [
    plugins: [FilterFormatter],
    filter_formatter: [
      [
        sigils: [:SQL],
        executable: "sqlformat",
        args: ["format", "-", "--dialect", "postgres", "--nocolor", "--disable-progress-bar"]
      ]
    ]
  ]
  ```

  ## Options

  The only supported option is `:filter_formatter` which takes a list of
  configurations, each describing a list of sigils/file extensions and the
  command line to use for filtering. Each configuration is a keyword list,
  supporting the following keys:

  * `:sigils`- a list of stoms identifying sigils for which content should be
  filtered.

  * `:extensions` - a list of extensions (including the dot, e.g. `.md` or
  `.sql`) identifying files to be filtered. Make sure to also include these files
  in the `:inputs` option of `.formatter.exs`!

  * `:executable` - required; a filter program to invoke for formatting. If just a file
  name is given, the program is expected to be found via the `PATH` environment
  variable.

  * `:args` - optional; a list of binaries with arguments to pass to the
  executable.

  At least one of `:sigils` and `:extensions` should be specified.
  """

  @behaviour Mix.Tasks.Format

  require Logger

  @impl Mix.Tasks.Format
  def features(opts) do
    formatter_opts = opts[:filter_formatter] || []

    [
      sigils: Enum.flat_map(formatter_opts, &(&1[:sigils] || [])),
      extensions: Enum.flat_map(formatter_opts, &(&1[:extensions] || []))
    ]
  end

  @impl Mix.Tasks.Format
  def format(contents, opts) do
    config =
      if sigil = opts[:sigil] do
        Enum.find(opts[:filter_formatter], fn config -> sigil in config[:sigils] end)
      else
        ext = opts[:extension]
        Enum.find(opts[:filter_formatter], fn config -> ext in config[:extensions] end)
      end

    args = config[:args] || []

    result =
      case config[:executable] do
        nil -> {:error, "missing executable field in configuration"}
        exe -> Rambo.run(exe, args, in: contents, log: false)
      end

    case result do
      {:ok, %Rambo{status: 0, out: output}} ->
        output

      {:error, %Rambo{status: status, err: err}} ->
        Logger.warning(
          "FilterFormatter.format/2: running #{config[:executable]} failed with status code #{status}:\n#{err}"
        )

        contents

      {:error, what} ->
        Logger.warning(
          "FilterFormatter.format/2: failed to execute #{config[:executable]}: #{what}"
        )

        contents
    end
  end
end
