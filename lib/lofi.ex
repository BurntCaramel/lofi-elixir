defmodule Lofi do
  @moduledoc """
  A library for #lofi parsing
  """

  defmodule Element do
    defstruct texts: [], mentions: [], tags: %{}
  end
end
