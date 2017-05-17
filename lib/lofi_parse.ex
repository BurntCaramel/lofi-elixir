defmodule Lofi.Parse do
  @moduledoc """
  Parses Lofi content into a structure of text, tags, and mentions.
  """

  @tags_regex ~r/\B#[A-Za-z0-9_-]+(:\s*[^#]*)?/
  @tag_key_value_regex ~r/\B#([a-zA-Z0-9-_]+)(:\s*([^#]*))?/

  defp clean_text(input) do
    Regex.replace(@tags_regex, input, "")
  end

  defp parse_tag_key_value(input) do
    case Regex.run(@tag_key_value_regex, input) do
      [_whole, key] ->
        {key, {:flag, true}}
      [_whole, key, _left, value] ->
        {key, {:value, String.trim(value)}}
    end
  end

  defp parse_tags(input) do
    Regex.scan(@tags_regex, input)
    |> Enum.map( fn l ->
      l
      |> List.first
      |> parse_tag_key_value
    end)
    |> Map.new
  end

  @doc """
  Hello world.

  ## Examples

      iex> Lofi.Parse.parse_element("hello")
      %Lofi.Element{ text: "hello", tags: %{} }

  """
  def parse_element(raw_string) when is_bitstring(raw_string) do
    trimmed_string = raw_string
      |> clean_text
      |> String.trim
    tags = parse_tags(raw_string)
    %Lofi.Element{ text: trimmed_string, tags: tags }
  end
end
