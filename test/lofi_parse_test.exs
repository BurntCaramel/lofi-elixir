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

  test "parse just mentions" do
    assert Parse.parse_element("@first-name") == %Element{ texts: [""], mentions: [["first-name"]] }
  end

  test "parse text with mentions" do
    assert Parse.parse_element("hello @first-name") == %Element{ texts: ["hello "], mentions: [["first-name"]] }
    assert Parse.parse_element("hello @first-name @last-name") == %Element{ texts: ["hello ", " "], mentions: [["first-name"], ["last-name"]] }
    assert Parse.parse_element("hello @first-name@last-name") == %Element{ texts: ["hello ", ""], mentions: [["first-name"], ["last-name"]] }
    assert Parse.parse_element("first: @first-name last: @last-name") == %Element{ texts: ["first: ", " last: "], mentions: [["first-name"], ["last-name"]] }
    assert Parse.parse_element("first: @first-name last: @last-name suffix") == %Element{ texts: ["first: ", " last: ", " suffix"], mentions: [["first-name"], ["last-name"]] }
    assert Parse.parse_element("first: @first-name last: @last-name.") == %Element{ texts: ["first: ", " last: ", "."], mentions: [["first-name"], ["last-name"]] }
  end

  test "parse text with mentions key path" do
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

  test "parse tag value with mentions" do
    assert Parse.parse_element("#table #title: @person.name") == %Element{ tags: %{ "table" => {:flag, true}, "title" => {:content, %{ texts: [""], mentions: [["person", "name"]] }} } }
    assert Parse.parse_element("#table #title: @person.name @person.last") == %Element{ tags: %{ "table" => {:flag, true}, "title" => {:content, %{ texts: ["", " "], mentions: [["person", "name"], ["person", "last"]] }} } }
    assert Parse.parse_element("#table #title: a @person.name b @person.last") == %Element{ tags: %{ "table" => {:flag, true}, "title" => {:content, %{ texts: ["a ", " b "], mentions: [["person", "name"], ["person", "last"]] }} } }
    assert Parse.parse_element(" #table #title: @person.name ") == %Element{ tags: %{ "table" => {:flag, true}, "title" => {:content, %{ texts: [""], mentions: [["person", "name"]] }} } }
  end

  test "parse introduction" do
    assert Parse.parse_element("@user: hello") == %Element{ introducing: "user", texts: ["hello"] }
    assert Parse.parse_element("@user:") == %Element{ introducing: "user", texts: [""] }
    assert Parse.parse_element("@user: ") == %Element{ introducing: "user", texts: [""] }
    assert Parse.parse_element("@title: #text") == %Element{ introducing: "title", tags: %{ "text" => {:flag, true} } }
    assert Parse.parse_element("@example: @person.name") == %Element{ introducing: "example", texts: [""], mentions: [["person", "name"]] }
    assert Parse.parse_element("@example: hello #key: value") == %Element{ introducing: "example", texts: ["hello"], tags: %{ "key" => {:content, %{ texts: ["value"], mentions: [] } } } }
    assert Parse.parse_element(" @example: hello #key: value") == %Element{ introducing: "example", texts: ["hello"], tags: %{ "key" => {:content, %{ texts: ["value"], mentions: [] } } } }
  end

  test "parse section" do
    assert Parse.parse_section("""
hello
is
it
me
you’re
looking
for?
"""
) == [ %Element{ texts: ["hello"] }, %Element{ texts: ["is"] }, %Element{ texts: ["it"] }, %Element{ texts: ["me"] }, %Element{ texts: ["you’re"] }, %Element{ texts: ["looking"] }, %Element{ texts: ["for?"] } ]

    assert Parse.parse_section("""
top
- inner
"""
) == [ %Element{ texts: ["top"], children: [ %Element{ texts: ["inner"] } ] } ]

    assert Parse.parse_section("""
top
- inner1
- inner2
"""
) == [ %Element{ texts: ["top"], children: [ %Element{ texts: ["inner1"] }, %Element{ texts: ["inner2"] } ] } ]

    assert Parse.parse_section("""
top1
- inner1
- inner2
top2
- inner3
- inner4
"""
  ) == [
      %Element{ texts: ["top1"], children: [ %Element{ texts: ["inner1"] }, %Element{ texts: ["inner2"] } ] },
      %Element{ texts: ["top2"], children: [ %Element{ texts: ["inner3"] }, %Element{ texts: ["inner4"] } ] }
    ]

  assert Parse.parse_section("""
above
top1
- inner1
- inner2
top2
- inner3
- inner4
below
"""
  ) == [
      %Element{ texts: ["above"] },
      %Element{ texts: ["top1"], children: [ %Element{ texts: ["inner1"] }, %Element{ texts: ["inner2"] } ] },
      %Element{ texts: ["top2"], children: [ %Element{ texts: ["inner3"] }, %Element{ texts: ["inner4"] } ] },
      %Element{ texts: ["below"] }
    ]

    assert Parse.parse_section("""
above #first
top1 #second: 2nd
- inner1 #third
- @inner2.and.then.some #fourth
@top2 #fifth: @mentioning.something
- inner3 #sixth
- inner4 #seventh
below #eighth
"""
  ) == [
      %Element{ texts: ["above"], tags: %{ "first" => {:flag, true} } },
      %Element{ texts: ["top1"], tags: %{ "second" => {:content, %{ texts: ["2nd"], mentions: [] }} }, children: [
        %Element{ texts: ["inner1"], tags: %{ "third" => {:flag, true} } },
        %Element{ mentions: [["inner2", "and", "then", "some"]], tags: %{ "fourth" => {:flag, true} } }
      ] },
      %Element{ mentions: [["top2"]], tags: %{ "fifth" => {:content, %{ texts: [""], mentions: [["mentioning", "something"]] }} }, children: [
        %Element{ texts: ["inner3"], tags: %{ "sixth" => {:flag, true} } },
        %Element{ texts: ["inner4"], tags: %{ "seventh" => {:flag, true} } }
      ] },
      %Element{ texts: ["below"], tags: %{ "eighth" => {:flag, true} } }
    ]

  end
end
