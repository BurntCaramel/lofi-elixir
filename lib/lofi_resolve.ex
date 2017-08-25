defmodule Lofi.Resolve do
  @moduledoc """
  Resolve content, plugging in mention values
  """

  @doc """
  Resolve string from `texts` and `mentions`, substituting values for any @mentions found by calling `get_mention_value` with the mention key
  """
  def resolve_content(texts, mentions, get_mention_value) when is_function(get_mention_value) do
    [texts, mentions]
    |> List.zip
    |> Enum.flat_map(fn({text, mention}) -> [text, get_mention_value.(mention)] end)
    |> Enum.join
  end

  @doc """
  Resolve string from `texts` and `mentions`, substituting values for any @mentions found by looking up value in map `values` for the mention key, defaulting to `fallback_value` if mention key not present
  """
  def resolve_content(texts, mentions, values, fallback_value) when is_map(values) do
    resolve_content(texts, mentions, fn(key) -> Map.get(values, key, fallback_value) end)
  end

  @doc """
  Resolve string from `texts` and `mentions`, substituting values for any @mentions found by looking up value in map `values` for the mention key, raising `KeyError` if mention key not present
  """
  def resolve_content!(texts, mentions, values) when is_map(values) do
    resolve_content(texts, mentions, fn(key) -> Map.fetch!(values, key) end)
  end
end