defmodule LofiResolveTest do
  use ExUnit.Case
  alias Lofi.Resolve
  doctest Lofi.Resolve

  test "resolve_content with map" do
    texts = ["Welcome ", " "]
    mentions = [["first_name"], ["last_name"]]

    assert Resolve.resolve_content(texts, mentions, %{
      ["first_name"] => "John",
      ["last_name"] => "Smith"
    }, "") == "Welcome John Smith"

    assert Resolve.resolve_content(texts, mentions, %{
      ["first_name"] => "John"
    }, "") == "Welcome John "

    assert_raise KeyError, fn ->
      Resolve.resolve_content!(texts, mentions, %{
        ["first_name"] => "John"
      })
    end
  end

  test "resolve_content with function" do
    texts = ["Welcome ", " "]
    mentions = [["first_name"], ["last_name"]]

    assert Resolve.resolve_content(texts, mentions, fn(key) ->
      case key do
        ["first_name"] -> "John"
        ["last_name"] -> "Smith"
      end
    end) == "Welcome John Smith"

    assert_raise CaseClauseError, fn ->
      Resolve.resolve_content(texts, mentions, fn(key) ->
        case key do
          ["first_name"] -> "John"
        end
      end)
    end
  end
end