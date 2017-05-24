defmodule Lofi.Parse do
  @moduledoc """
  Parses Lofi content into a structure of text, tags, and mentions.
  """

  @tags_regex ~r/\B#[A-Za-z0-9_-]+(:\s*[^#]*)?/
  @tag_key_value_regex ~r/\B#([a-zA-Z0-9-_]+)(:\s*([^#]*))?/
  @mentions_regex ~r/@([a-zA-Z0-9_-]+(?:\.[a-zA-Z0-9-_]+)*)/
  @introduction_regex ~r/^@([a-zA-Z0-9_-]+):/

  defp clean_text(input) do
    Regex.replace(@tags_regex, input, "")
    |> String.trim
  end

  defp parse_tag_key_value(input) do
    case Regex.run(@tag_key_value_regex, input) do
      [_whole, key] ->
        {key, {:flag, true}}
      [_whole, key, _left, value] ->
        {key, {:content, parse_texts_and_mentions(value)}}
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

  defp parse_mention(input) do
    String.slice(input, 1..-1) # Remove leading @
    |> String.split(".")
  end

  defp parse_introduction(input) do
    introduction_indexes = Regex.run(@introduction_regex, input, return: :index, include_captures: true)
    case introduction_indexes do
      nil ->
        { nil, input }
      [_full_range, {start, len}] ->
        {
          String.slice(input, start, len),
          String.slice(input, start+len+1..-1)
          |> String.trim
        }
    end
  end

  defp parse_texts_and_mentions(input) when is_bitstring(input) do
    no_tags_input = clean_text(input)
    texts_and_mentions = Regex.split(@mentions_regex, no_tags_input, include_captures: true)
    process_texts_and_mentions(texts_and_mentions, [], [])
  end

  defp process_texts_and_mentions([ "" ], texts, mentions) do
    process_texts_and_mentions([], texts, mentions)
  end

  defp process_texts_and_mentions([ text ], texts, mentions) do
    process_texts_and_mentions([], [ text | texts ], mentions)
  end

  defp process_texts_and_mentions([ text | [ mention | rest ] ], texts, mentions) do
    process_texts_and_mentions(rest, [ text | texts ], [ parse_mention(mention) | mentions ])
  end

  defp process_texts_and_mentions([], texts, mentions) do
    %{ texts: Enum.reverse(texts), mentions: Enum.reverse(mentions) }
  end

  @doc """
  Parses Lofi content into a structure of text, tags, and mentions.

  ## Examples

      iex> Lofi.Parse.parse_element("hello")
      %Lofi.Element{ texts: ["hello"], tags: %{} }

      iex> Lofi.Parse.parse_element("Click me #button")
      %Lofi.Element{ texts: ["Click me"], tags: %{ "button" => {:flag, true} } }

      iex> Lofi.Parse.parse_element("hello @first-name @last-name")
      %Lofi.Element{ texts: ["hello ", " "], mentions: [["first-name"], ["last-name"]] }

  """
  def parse_element(input) when is_bitstring(input) do
    {introducing, rest} = input
      |> String.trim
      |> parse_introduction

    %{ texts: texts, mentions: mentions } = parse_texts_and_mentions(rest)
    tags = parse_tags(rest)
    %Lofi.Element{ introducing: introducing, texts: texts, mentions: mentions, tags: tags }
  end
end
