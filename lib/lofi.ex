defmodule Lofi do
  @moduledoc """
  A library for #lofi parsing
  """

  defmodule Element do
    defstruct introducing: nil, texts: [""], mentions: [], tags: %{}, children: []
  end
end
