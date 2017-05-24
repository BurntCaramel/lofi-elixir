defmodule LofiParseTest do
  use ExUnit.Case
  alias Lofi.Parse, as: Parse
  alias Lofi.Element, as: Element
  doctest Lofi.Parse

  test "parse text" do
    assert Parse.parse_element("hello") == %Element{ texts: ["hello"] }
    assert Parse.parse_element(" hello") == %Element{ texts: ["hello"] }
    assert Parse.parse_element("hello ") == %Element{ texts: ["hello"] }
    assert Parse.parse_element(" hello ") == %Element{ texts: ["hello"] }
  end

  test "parse text with tags" do
    assert Parse.parse_element("hello #button") == %Element{ texts: ["hello"], tags: %{ "button" => {:flag, true} } }
    assert Parse.parse_element("hello #variation: danger") == %Element{ texts: ["hello"], tags: %{ "variation" => {:content, %{ texts: ["danger"], mentions: [] }} } }
    assert Parse.parse_element("hello #button #variation: danger") == %Element{texts: ["hello"], tags: %{ "button" => {:flag, true}, "variation" => {:content, %{ texts: ["danger"], mentions: [] }} } }
    assert Parse.parse_element("hello #button #variation: danger ") == %Element{texts: ["hello"], tags: %{ "button" => {:flag, true}, "variation" => {:content, %{ texts: ["danger"], mentions: [] }} } }
    assert Parse.parse_element("hello #variation: danger #button") == %Element{ texts: ["hello"], tags: %{ "button" => {:flag, true}, "variation" => {:content, %{ texts: ["danger"], mentions: [] }} } }
    assert Parse.parse_element("hello #variation: danger #button ") == %Element{ texts: ["hello"], tags: %{ "button" => {:flag, true}, "variation" => {:content, %{ texts: ["danger"], mentions: [] }} } }
  end

  test "parse text with mentions" do
    assert Parse.parse_element("hello @first-name") == %Element{ texts: ["hello "], mentions: [["first-name"]] }
    assert Parse.parse_element("hello @first-name @last-name") == %Element{ texts: ["hello ", " "], mentions: [["first-name"], ["last-name"]] }
    assert Parse.parse_element("hello @first-name@last-name") == %Element{ texts: ["hello ", ""], mentions: [["first-name"], ["last-name"]] }
    assert Parse.parse_element("first: @first-name last: @last-name") == %Element{ texts: ["first: ", " last: "], mentions: [["first-name"], ["last-name"]] }
    assert Parse.parse_element("first: @first-name last: @last-name suffix") == %Element{ texts: ["first: ", " last: ", " suffix"], mentions: [["first-name"], ["last-name"]] }
    assert Parse.parse_element("first: @first-name last: @last-name.") == %Element{ texts: ["first: ", " last: ", "."], mentions: [["first-name"], ["last-name"]] }
  end

  test "parse just mentions" do
    assert Parse.parse_element("@first-name") == %Element{ texts: [""], mentions: [["first-name"]] }
  end

  test "parse text with mentions nested key path" do
    assert Parse.parse_element("hello @person.name") == %Element{ texts: ["hello "], mentions: [["person", "name"]] }
    assert Parse.parse_element("hello @person.name.") == %Element{ texts: ["hello ", "."], mentions: [["person", "name"]] }
    assert Parse.parse_element("hello @person.name @person.last") == %Element{ texts: ["hello ", " "], mentions: [["person", "name"], ["person", "last"]] }
  end

  test "parse text with tags and mentions" do
    assert Parse.parse_element("hello @person.name #button") == %Element{ texts: ["hello "], mentions: [["person", "name"]], tags: %{ "button" => {:flag, true} } }
    assert Parse.parse_element("hello @person.name @person.last #button") == %Element{ texts: ["hello ", " "], mentions: [["person", "name"], ["person", "last"]], tags: %{ "button" => {:flag, true} } }
    assert Parse.parse_element("hello @person.name @person.last #key: value") == %Element{ texts: ["hello ", " "], mentions: [["person", "name"], ["person", "last"]], tags: %{ "key" => {:content, %{ texts: ["value"], mentions: [] }} } }
    assert Parse.parse_element(" hello @person.name @person.last #key: value ") == %Element{ texts: ["hello ", " "], mentions: [["person", "name"], ["person", "last"]], tags: %{ "key" => {:content, %{ texts: ["value"], mentions: [] }} } }
  end

  test "parse tag text with mentions" do
    assert Parse.parse_element("#table #title: @person.name") == %Element{ texts: [], mentions: [], tags: %{ "table" => {:flag, true}, "title" => {:content, %{ texts: [""], mentions: [["person", "name"]] }} } }
    assert Parse.parse_element(" #table #title: @person.name ") == %Element{ texts: [], mentions: [], tags: %{ "table" => {:flag, true}, "title" => {:content, %{ texts: [""], mentions: [["person", "name"]] }} } }
  end

  test "parse introduction" do
    assert Parse.parse_element("@user: hello") == %Element{ introducing: "user", texts: ["hello"] }
    assert Parse.parse_element("@title: #text") == %Element{ introducing: "title", tags: %{ "text" => {:flag, true} } }
    assert Parse.parse_element("@example: hello #key: value") == %Element{ introducing: "example", texts: ["hello"], tags: %{ "key" => {:content, %{ texts: ["value"], mentions: [] } } } }
    assert Parse.parse_element(" @example: hello #key: value") == %Element{ introducing: "example", texts: ["hello"], tags: %{ "key" => {:content, %{ texts: ["value"], mentions: [] } } } }
  end
end
