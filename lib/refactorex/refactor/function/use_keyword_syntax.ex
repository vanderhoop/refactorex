defmodule Refactorex.Refactor.Function.UseKeywordSyntax do
  use Refactorex.Refactor,
    title: "Rewrite function using keyword syntax",
    kind: "refactor.rewrite"

  alias Refactorex.Refactor.Function

  def can_refactor?(%{node: {_, meta, _} = node} = zipper, range) do
    cond do
      not Function.definition?(node) ->
        false

      # keyword functions don't have :do tag
      is_nil(meta[:do]) ->
        :skip

      Function.has_multiple_statements?(zipper) ->
        :skip

      not SelectionRange.starts_on_node_line?(range, node) ->
        :skip

      true ->
        true
    end
  end

  def can_refactor?(_, _), do: false

  def refactor(zipper) do
    zipper
    |> Z.update(fn {id, meta, macro} ->
      {id, Keyword.drop(meta, [:do, :end]), macro}
    end)
    |> Function.go_to_block()
    |> Z.update(fn {{:__block__, meta, [:do]}, macro} ->
      {{:__block__, Keyword.put(meta, :format, :keyword), [:do]}, macro}
    end)
  end
end
