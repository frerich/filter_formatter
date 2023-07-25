defmodule FilterFormatterTest do
  use ExUnit.Case, async: false

  import Mock

  describe "features/1" do
    test "no filter_formatter options" do
      assert [sigils: [], extensions: []] == FilterFormatter.features([])
    end

    test "config with only sigils" do
      assert [sigils: [:a, :b], extensions: []] ==
               FilterFormatter.features(
                 filter_formatter: [
                   [
                     sigils: [:a, :b]
                   ]
                 ]
               )
    end

    test "config with only extensions" do
      assert [sigils: [], extensions: [".aaa", ".bbb"]] ==
               FilterFormatter.features(
                 filter_formatter: [
                   [
                     extensions: [".aaa", ".bbb"]
                   ]
                 ]
               )
    end

    test "multiple configs with sigils and extensions" do
      assert [sigils: [:a, :x, :y], extensions: [".aaa", ".bbb", ".zzz"]] ==
               FilterFormatter.features(
                 filter_formatter: [
                   [
                     sigils: [:a],
                     extensions: [".aaa", ".bbb"]
                   ],
                   [
                     sigils: [:x, :y],
                     extensions: [".zzz"]
                   ]
                 ]
               )
    end
  end

  describe "format/2" do
    test "picks right configuration when invoked for a sigil" do
      config = [
        [sigils: [:a], executable: "exe_a"],
        [sigils: [:a], executable: "exe_b"]
      ]

      contents = "dummy content"
      opts = [filter_formatter: config, sigil: :a]

      with_mock Rambo,
        run: fn exe, _args, _opts -> {:ok, %Rambo{status: 0, out: "#{exe} output"}} end do
        assert "exe_a output" == FilterFormatter.format(contents, opts)
      end
    end

    test "picks right configuration when invoked for a file" do
      config = [
        [extensions: [".aaa"], executable: "exe_a"],
        [extensions: [".aaa"], executable: "exe_b"]
      ]

      contents = "dummy content"
      opts = [filter_formatter: config, extension: ".aaa"]

      with_mock Rambo,
        run: fn exe, _args, _opts -> {:ok, %Rambo{status: 0, out: "#{exe} output"}} end do
        assert "exe_a output" == FilterFormatter.format(contents, opts)
      end
    end

    test "gracefully handles missing executable field" do
      config = [
        [extensions: [".aaa"]]
      ]

      contents = "dummy content"
      opts = [filter_formatter: config, extension: ".aaa"]

      assert "dummy content" == FilterFormatter.format(contents, opts)
    end

    test "gracefully handles executable binary missing" do
      config = [
        [extensions: [".aaa"], executable: "doesnotexist"]
      ]

      contents = "dummy content"
      opts = [filter_formatter: config, extension: ".aaa"]

      with_mock Rambo, run: fn "doesnotexist", [], _opts -> {:error, "file does not exist"} end do
        assert "dummy content" == FilterFormatter.format(contents, opts)
      end
    end

    test "gracefully handles executable returning non-zero output" do
      config = [
        [extensions: [".aaa"], executable: "arthur"]
      ]

      contents = "dummy content"
      opts = [filter_formatter: config, extension: ".aaa"]

      with_mock Rambo,
        run: fn "arthur", [], _opts ->
          {:error, %Rambo{status: 42, err: "computing meaning of life"}}
        end do
        assert "dummy content" == FilterFormatter.format(contents, opts)
      end
    end
  end
end
