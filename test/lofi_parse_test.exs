defmodule LofiParseTest do
  use ExUnit.Case
  alias Lofi.Parse, as: Parse
  alias Lofi.Element, as: Element
  doctest Lofi.Parse

  test "parse text" do
    assert Parse.parse_element("hello") == %Element{ text: "hello", tags: %{} }
    assert Parse.parse_element(" hello") == %Element{ text: "hello", tags: %{} }
    assert Parse.parse_element("hello ") == %Element{ text: "hello", tags: %{} }
    assert Parse.parse_element(" hello ") == %Element{ text: "hello", tags: %{} }
  end

  test "parse text with hashtags" do
    assert Parse.parse_element("hello #button") == %Element{ text: "hello", tags: %{ "button" => {:flag, true} } }
    assert Parse.parse_element("hello #variation: danger") == %Element{ text: "hello", tags: %{ "variation" => {:value, "danger"} } }
    assert Parse.parse_element("hello #button #variation: danger") == %Element{text: "hello", tags: %{ "button" => {:flag, true}, "variation" => {:value, "danger"} } }
    assert Parse.parse_element("hello #variation: danger #button") == %Element{ text: "hello", tags: %{ "button" => {:flag, true}, "variation" => {:value, "danger"} } }
  end
end
