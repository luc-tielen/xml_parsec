defmodule XML.Parser.Test do
  use ExUnit.Case, async: true
  use Combine
  alias XML.Parser
  alias XML.Tag

  test "parsing XML comments" do
    assert parse_comment("") == {:error, "Expected `<!--`, but was not found at line 1, column 0."}
    assert parse_comment("<!--") == {:error, "Expected `-->`, but was not found at line 1, column 4."}
    assert parse_comment("-->") == {:error, "Expected `<!--`, but was not found at line 1, column 0."}
    assert parse_comment("<!---->") == ""
    assert parse_comment("<!-- -->") == " "
    assert parse_comment("<!------->") == "---"
    assert parse_comment("<!-- a -->") == " a "
    assert parse_comment("<!-- ab -->") == " ab "
    assert parse_comment("<!-- ab -->") == " ab "
    assert parse_comment("<!-- a\nb -->") == " a\nb "
    assert parse_comment("<!-- a<!-- b -->-->") ==
      {:error, "Expected `-->`, but was not found at line 1, column 6."}
  end

  test "parsing XML strings" do
    assert parse_string("") == ""
    assert parse_string("a") == "a"
    assert parse_string("ab") == "ab"
    assert parse_string("ab<c") == "ab"
    # TODO comment in between
  end

  test "parsing XML tag attributes" do
    assert parse_attr("a=\"b\"") == {"a", "b"}
    assert parse_attr("a=\"bc\"") == {"a", "bc"}
    assert parse_attr("a=\" b \"") == {"a", " b "}
  end

  test "parsing XML tags without content" do
    assert parse_tag_no_content("<tag1/>")
        == %Tag{name: "tag1", attributes: %{}, value: nil}
    assert parse_tag_no_content("<tag2 a=\"b\"/>")
        == %Tag{name: "tag2", attributes: %{"a" => "b"}, value: nil}
    assert parse_tag_no_content("<tag3 a=\"b\" c=\"de\"/>")
        == %Tag{name: "tag3", attributes: %{"a" => "b", "c" => "de"}, value: nil}
  end

  test "parsing XML tags with content" do
    assert parse_tag_with_content("<tag1></tag1>")
        == %Tag{name: "tag1", attributes: %{}, value: ""}
    assert parse_tag_with_content("<tag2 a=\"b\"   ></tag2>")
        == %Tag{name: "tag2", attributes: %{"a" => "b"}, value: ""}
    assert parse_tag_with_content("<tag3 a=\"b\" c=\"de\">   a b    c   </tag3>")
        == %Tag{name: "tag3", attributes: %{"a" => "b", "c" => "de"},
                value: "   a b    c   "}
    assert parse_tag_with_content("<tag4 a=\"b\" c=\"de\"></tag5>")
        == {:error, xml_err("tag4", "tag5")}
    assert parse_tag_with_content("<tag6 a=\"b\" c=\"de\"><tag7/></tag6>")
        == %Tag{name: "tag6",
                attributes: %{"a" => "b", "c" => "de"},
                value: %Tag{name: "tag7", attributes: %{}}}
    assert parse_tag_with_content("<tag8 a=\"b\" c=\"de\"><tag9></tag9></tag8     >")
        == %Tag{name: "tag8",
                attributes: %{"a" => "b", "c" => "de"},
                value: %Tag{name: "tag9", attributes: %{}, value: ""}}
  end

  defp xml_err(tag1, tag2) do
    "XML tags do not line up! Start tag: #{tag1}, end tag: #{tag2}."
  end

  defp parse_comment(x), do: run_parser(x, Parser.comment_parser())
  defp parse_string(x), do: run_parser(x, Parser.string_parser())
  defp parse_attr(x), do: run_parser(x, Parser.attribute())
  defp parse_tag_no_content(x) do
    run_parser(x, Parser.tag_no_content_parser())
  end
  defp parse_tag_with_content(x) do
    run_parser(x, Parser.tag_with_content_parser())
  end

  defp run_parser(x, parser) do
    case Combine.parse(x, parser) do
      [value] -> value
      {:error, _} = err -> err
    end
  end
end
