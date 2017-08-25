defmodule LofiTagsTest do
  use ExUnit.Case
  alias Lofi.Tags
  doctest Lofi.Tags

  test "has_flag" do
    tags = %{"abc" => {:flag, true}, "name" => {:content, %{texts: ["Alice Jones"]}}}
    assert Tags.has_flag(tags, "abc")
    assert Tags.has_flag(tags, "def") == false
    assert Tags.has_flag(tags, "name") == false
  end

  test "get_content" do
    tags = %{"abc" => {:flag, true}, "name" => {:content, %{texts: ["Alice Jones"]}}}
    assert Tags.get_content(tags, "abc") == nil
    assert Tags.get_content(tags, "def") == nil
    assert Tags.get_content(tags, "name") == %{texts: ["Alice Jones"]}

    assert Tags.get_content(tags, "abc", "default") == "default"
    assert Tags.get_content(tags, "def", "default") == "default"
    assert Tags.get_content(tags, "name", "default") == %{texts: ["Alice Jones"]}
  end

  test "fetch_content" do
    tags = %{"abc" => {:flag, true}, "name" => {:content, %{texts: ["Alice Jones"]}}}
    assert Tags.fetch_content(tags, "abc") == {:error, :not_content}
    assert Tags.fetch_content(tags, "def") == {:error, :missing}
    assert Tags.fetch_content(tags, "name") == {:ok, %{texts: ["Alice Jones"]}}
  end
end