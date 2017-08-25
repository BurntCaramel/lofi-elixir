defmodule Lofi.Tags do
  @moduledoc """
  Utilities for working with Lofi element tags
  """

  @doc """
  Check whether a tags map has a certain flag tag

      iex> Lofi.Tags.has_flag(%{"abc" => {:flag, true}}, "abc")
      true

      iex> Lofi.Tags.has_flag(%{"abc" => {:flag, true}}, "def")
      false

      iex> Lofi.Tags.has_flag(%{"abc" => {:content, %{texts: ["text"]}}}, "abc")
      false
  """
  def has_flag(tags, name) do
    case tags do
      %{^name => {:flag, true}} -> true
      _ -> false
    end
  end

  @doc """
  Get value for a content tag

      iex> Lofi.Tags.get_content(%{"name" => {:content, %{texts: ["Alice Jones"]}}, "abc" => {:flag, true}}, "name")
      %{texts: ["Alice Jones"]}

      iex> Lofi.Tags.get_content(%{"name" => {:content, %{texts: ["Alice Jones"]}}, "abc" => {:flag, true}}, "abc")
      nil

      iex> Lofi.Tags.get_content(%{"name" => {:content, %{texts: ["Alice Jones"]}}, "abc" => {:flag, true}}, "abc", "default")
      "default"
  """
  def get_content(tags, name, default \\ nil) do
    case tags do
      %{^name => {:content, value}} ->
        value
      _ ->
        default
    end
  end

  @doc """
  Fetches the value for a specific `name` in the given `tags`

      iex> Lofi.Tags.fetch_content(%{"name" => {:content, %{texts: ["Alice Jones"]}}, "abc" => {:flag, true}}, "name")
      {:ok, %{texts: ["Alice Jones"]}}

      iex> Lofi.Tags.fetch_content(%{"name" => {:content, %{texts: ["Alice Jones"]}}, "abc" => {:flag, true}}, "abc")
      {:error, :not_content}

      iex> Lofi.Tags.fetch_content(%{"name" => {:content, %{texts: ["Alice Jones"]}}, "abc" => {:flag, true}}, "def")
      {:error, :missing}
  """
  def fetch_content(tags, name) do
    case tags do
      %{^name => {:content, value}} ->
        {:ok, value}
      %{^name => _value} ->
        {:error, :not_content}
      _ ->
        {:error, :missing}
    end
  end
end