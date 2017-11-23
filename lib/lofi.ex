defmodule Lofi do
  @moduledoc """
  A library for #lofi parsing
  """

  defmodule Element do
    @moduledoc """
    A Lofi element struct, with texts, mentions, tags, children, and optionally, introducing
    """
    defstruct introducing: nil, texts: [""], mentions: [], tags_path: [], tags_hash: %{}, children: []
  end
end
