defmodule Refactorex.Refactor.VariableTest do
  use Refactorex.RefactorCase

  alias Refactorex.Refactor.Variable

  describe "inside_declaration?/1" do
    test "marks function arg as declaration" do
      zipper =
        go_to_selection("""
        #                  v
        def foo(%{"arg" => arg}) when arg == 10 do
        #                    ^
          arg + 10
        end
        """)

      assert Variable.inside_declaration?(zipper)
    end

    test "marks nested function arg as declaration" do
      zipper =
        go_to_selection("""
        #                              v
        def foo(%{"arg" => [_, {%{arg: arg}, _}]}) when arg == 10 do
        #                                ^
          arg + 10
        end
        """)

      assert Variable.inside_declaration?(zipper)
    end

    test "marks case clause arg as declaration" do
      zipper =
        go_to_selection("""
        case arg do
          #      v
          %{foo: foo} -> foo + 4
          #        ^
          _ -> 42
        end
        """)

      assert Variable.inside_declaration?(zipper)
    end

    test "marks with clause arg as declaration" do
      zipper =
        go_to_selection("""
        #          v
        with {:ok, arg} <- foo(b) do
        #            ^
          arg2
        end
        """)

      assert Variable.inside_declaration?(zipper)
    end

    test "marks with anonymous function arg as declaration" do
      zipper =
        go_to_selection("""
        #  v
        fn arg -> arg + 40 end
        #    ^
        """)

      assert Variable.inside_declaration?(zipper)
    end

    test "marks everything inside guard as declaration" do
      zipper =
        go_to_selection("""
        #                 v
        def foo(arg) when arg == 10 do
        #                   ^
          arg + 45
        end
        """)

      assert Variable.inside_declaration?(zipper)

      zipper =
        go_to_selection("""
        #            v
        defguard foo(arg) when arg == 10
        #              ^
        """)

      assert Variable.inside_declaration?(zipper)
    end

    test "doesn't mark variable usage as declaration" do
      zipper =
        go_to_selection("""
        def foo(arg) do
        # v
          foo + 10
        #   ^
        end
        """)

      refute Variable.inside_declaration?(zipper)
    end

    test "doesn't mark function call as declaration" do
      zipper =
        go_to_selection("""
        def foo(arg) do
        # v
          bar(foo) + 10
        #        ^
        end
        """)

      refute Variable.inside_declaration?(zipper)
    end

    defp go_to_selection(original) do
      range = range_from_markers(original)
      original = remove_markers(original)

      {:ok, selection} = Refactorex.Parser.selection_or_line(original, range)

      original
      |> text_to_zipper()
      |> Sourceror.Zipper.traverse_while(nil, fn
        %{node: ^selection} = zipper, _ ->
          {:halt, zipper, zipper}

        zipper, _ ->
          {:cont, zipper, nil}
      end)
      |> elem(1)
    end
  end
end