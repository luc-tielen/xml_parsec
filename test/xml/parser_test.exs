defmodule XML.Parser.Test do
  use ExUnit.Case, async: true
  use Combine
  alias XML.Parser
  alias XML.Doc
  alias XML.Tag


  test "parsing XML documents" do
    assert parse_xml_doc("<?xml version=\"1.0\" encoding=\"UTF-8\"?><a/>")
      == %Doc{version: "1.0", encoding: "UTF-8", standalone: "yes",
              body: %Tag{name: "a", value: nil, attributes: %{}}}
    assert parse_xml_doc("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n <a/>")
      == %Doc{version: "1.0", encoding: "UTF-8", standalone: "yes",
              body: %Tag{name: "a", value: nil, attributes: %{}}}
    assert parse_xml_doc("<?xml version=\"1.0\" encoding=\"UTF-8\"?><a></a>")
      == %Doc{version: "1.0", encoding: "UTF-8", standalone: "yes",
              body: %Tag{name: "a", value: [], attributes: %{}}}
    assert parse_xml_doc("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n <a></a>")
      == %Doc{version: "1.0", encoding: "UTF-8", standalone: "yes",
              body: %Tag{name: "a", value: [], attributes: %{}}}
    assert parse_xml_doc(File.read!("test/fixtures/fixture3.xml"))
      == {:error, "Expected `<?xml`, but was not found at line 1, column 0."}
    assert parse_xml_doc(File.read!("test/fixtures/fixture2.xml"))
      == %Doc{version: "1.0", encoding: "UTF-8", standalone: "yes",
              body: %Tag{attributes: %{}, name: "root", value: [
                "\n  ",
                %Tag{attributes: %{}, name: "child", value: [
                  "\n    ",
                  %Tag{attributes: %{}, name: "subchild", value: ["content"]},
                  "\n    ",
                  %Tag{attributes: %{}, name: "tag_without_content", value: nil},
                  "\n  "
                ]},
                "\n"
              ]}}
    assert parse_xml_doc(File.read!("test/fixtures/fixture1.xml"))
      == %Doc{version: "1.0", encoding: "UTF-8", standalone: "yes",
              body: %Tag{attributes: %{}, name: "shiporder", value: [
                "\n",
                %Tag{attributes: %{}, name: "orderperson", value: ["John Smith"]},
                "\n",
                %Tag{attributes: %{}, name: "shipto", value: [
                  "\n  ",
                  %Tag{attributes: %{}, name: "name", value: ["Ola Nordmann"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "address", value: ["Langgt 23"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "city", value: ["4000 Stavanger"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "country", value: ["Norway"]},
                  "\n"
                ]},
                "\n",
                %Tag{attributes: %{}, name: "item", value: [
                  "\n  ",
                  %Tag{attributes: %{}, name: "title", value: ["Empire Burlesque"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "note", value: ["Special Edition"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "quantity", value: ["1"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "price", value: ["10.90"]},
                  "\n"
                ]},
                "\n",
                %Tag{attributes: %{}, name: "item", value: [
                  "\n  ",
                  %Tag{attributes: %{}, name: "title", value: ["Hide your heart"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "quantity", value: ["1"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "price", value: ["9.90"]},
                  "\n"
                ]},
                "\n"
              ]}}
  end

  test "parsing XML body" do
    # mismatched XML tags:
    assert parse_xml_body(File.read!("test/fixtures/fixture3.xml"))
      == {:error, "Expected at least one parser to succeed at line 1, column 0."}
    assert parse_xml_body("<xml>")
      == {:error, "Expected at least one parser to succeed at line 1, column 0."}
    assert parse_xml_body("<xml></xml>") == %Tag{attributes: %{}, name: "xml", value: []}
    assert parse_xml_body("<xml/>") == %Tag{attributes: %{}, name: "xml", value: nil}
    assert parse_xml_body("<xml><tag a=\"1\"/></xml>")
      == %Tag{attributes: %{}, name: "xml",
              value: [%Tag{attributes: %{"a" => "1"}, name: "tag", value: nil}]}
    assert parse_xml_body("<a>\n<b/>\n<c/>\n</a>")
      == %Tag{attributes: %{}, name: "a",
              value: [
                "\n",
                %Tag{name: "b", attributes: %{}, value: nil},
                "\n",
                %Tag{name: "c", attributes: %{}, value: nil},
                "\n",
              ]}
    assert parse_xml_body("<a>\n<b></b>\n<c>d</c>\n</a>")
      == %Tag{attributes: %{}, name: "a",
              value: [
                "\n",
                %Tag{name: "b", attributes: %{}, value: []},
                "\n",
                %Tag{name: "c", attributes: %{}, value: ["d"]},
                "\n",
              ]}
  end

  test "parsing XML doc header" do
    assert parse_xml_header("") == {:error, "Expected `<?xml`, but was not found at line 1, column 0."}
    assert parse_xml_header("<?xml?>") == {:error, "Expected `version` attribute in XML header!"}
    assert parse_xml_header("<?xml ?>") == {:error, "Expected `version` attribute in XML header!"}
    assert parse_xml_header("<?xml version=\"1.0\"?>") == %{"version" => "1.0"}
    assert parse_xml_header("<?xml version=\"1.0\" ?>") == %{"version" => "1.0"}
    assert parse_xml_header("<?xml version=\"1.0\" encoding=\"utf-8\" ?>") == %{"version" => "1.0", "encoding" => "utf-8"}
    assert parse_xml_header("<?xml version=\"1.0\" invalid_key=\"utf-8\" ?>") == {:error, "Expected `?>`, but was not found at line 1, column 20."}
    assert parse_xml_header("<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>")
      == %{"version" => "1.0", "encoding" => "utf-8", "standalone" => "yes"}
    assert parse_xml_header("<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>")
      == %{"version" => "1.0", "encoding" => "utf-8", "standalone" => "no"}
  end

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
    assert parse_string("") == {:error, "Expected at least one parser to succeed at line 1, column 0."}
    assert parse_string("a") == "a"
    assert parse_string("ab") == "ab"
    assert parse_string("ab<c") == "ab"
    assert parse_string("ab\n c") == "ab\n c"
    assert parse_string("ab<!-- c -->d") == "abd"
    assert parse_string("ab<!-- c --><!-- d -->e") == "abe"
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
        == %Tag{name: "tag1", attributes: %{}, value: []}
    assert parse_tag_with_content("<tag2 a=\"b\"   ></tag2>")
        == %Tag{name: "tag2", attributes: %{"a" => "b"}, value: []}
    assert parse_tag_with_content("<tag3 a=\"b\" c=\"de\">   a b    c   </tag3>")
        == %Tag{name: "tag3", attributes: %{"a" => "b", "c" => "de"},
                value: ["   a b    c   "]}
    assert parse_tag_with_content("<tag4 a=\"b\" c=\"de\"></tag5>")
        == {:error, xml_err("tag4", "tag5")}
    assert parse_tag_with_content("<tag6 a=\"b\" c=\"de\"><tag7/></tag6>")
        == %Tag{name: "tag6",
                attributes: %{"a" => "b", "c" => "de"},
                value: [%Tag{name: "tag7", attributes: %{}}]}
    assert parse_tag_with_content("<tag8 a=\"b\" c=\"de\"><tag9></tag9></tag8     >")
        == %Tag{name: "tag8",
                attributes: %{"a" => "b", "c" => "de"},
                value: [%Tag{name: "tag9", attributes: %{}, value: []}]}
    assert parse_tag_with_content("<tag10>\n <tag11/></tag10>")
      == %Tag{name: "tag10", attributes: %{},
              value: ["\n ", %Tag{name: "tag11", value: nil, attributes: %{}}]}
    assert parse_tag_with_content("<tag10>\n a<tag11/></tag10>")
      == %Tag{name: "tag10", attributes: %{},
              value: ["\n a", %Tag{name: "tag11", value: nil, attributes: %{}}]}
    assert parse_tag_with_content("<tag12><tag13/><tag14/></tag12>")
      == %Tag{name: "tag12", attributes: %{}, value: [
        %Tag{name: "tag13", attributes: %{}, value: nil},
        %Tag{name: "tag14", attributes: %{}, value: nil}
      ]}
  end

  defp xml_err(tag1, tag2), do: "XML tags do not line up! Start tag: #{tag1}, end tag: #{tag2}."

  defp parse_xml_doc(x), do: run_parser(x, Parser.xml_doc_parser())
  defp parse_xml_body(x), do: run_parser(x, Parser.xml_body_parser())
  defp parse_xml_header(x), do: run_parser(x, Parser.xml_header_parser())
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
