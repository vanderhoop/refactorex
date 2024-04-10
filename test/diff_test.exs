defmodule Refactorex.DiffTest do
  use ExUnit.Case

  alias Refactorex.Diff

  test "grabs ranges of modified text" do
    assert Diff.find_diffs(
             """
             defmodule Foo do
              def bar(arg) do
                arg
              end
             end
             """,
             """
             defmodule Foo do
              def bar(arg), do: arg
             end
             """
           ) == [
             %{
               text: " def bar(arg), do: arg",
               range: %{
                 start: %{line: 1, character: 0},
                 end: %{line: 3, character: 4}
               }
             }
           ]
  end

  test "grabs ranges of inserted text" do
    assert Diff.find_diffs(
             """
             defmodule Foo do
              def bar do
              end
             end
             """,
             """
             defmodule Foo do
              def bar do
              end

              def baz(arg) do
                arg + 10
              end
             end
             """
           ) == [
             %{
               text: "\n def baz(arg) do\n   arg + 10\n end\n",
               range: %{
                 start: %{line: 3, character: 0},
                 end: %{line: 3, character: 0}
               }
             }
           ]
  end

  test "grabs ranges of deleted text" do
    assert Diff.find_diffs(
             """
             defmodule Foo do
              def bar do
              end

              def baz(arg) do
                arg + 10
              end
             end
             """,
             """
             defmodule Foo do
              def bar do
              end
             end
             """
           ) == [
             %{
               text: "",
               range: %{
                 start: %{line: 3, character: 0},
                 end: %{line: 7, character: 4}
               }
             }
           ]
  end

  test "grabs no ranges form same text" do
    assert Diff.find_diffs(
             """
             defmodule Foo do
              def bar(arg) do
                arg
              end
             end
             """,
             """
             defmodule Foo do
              def bar(arg) do
                arg
              end
             end
             """
           ) == []
  end
end
