defmodule XML.Parser.Test do
  use ExUnit.Case, async: true
  alias XML.Parser.Internal, as: Parser
  alias XML.Doc
  alias XML.Tag

  test "parsing XML documents" do
    assert parse_xml_doc("<?xml version=\"1.0\" encoding=\"UTF-8\"?><a/>")
      == %Doc{version: "1.0", encoding: "UTF-8", standalone: "yes",
              body: %Tag{name: "a", values: nil, attributes: %{}}}
    assert parse_xml_doc("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n <a/>")
      == %Doc{version: "1.0", encoding: "UTF-8", standalone: "yes",
              body: %Tag{name: "a", values: nil, attributes: %{}}}
    assert parse_xml_doc("<?xml version=\"1.0\" encoding=\"UTF-8\"?><a></a>")
      == %Doc{version: "1.0", encoding: "UTF-8", standalone: "yes",
              body: %Tag{name: "a", values: [], attributes: %{}}}
    assert parse_xml_doc("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n <a></a>")
      == %Doc{version: "1.0", encoding: "UTF-8", standalone: "yes",
              body: %Tag{name: "a", values: [], attributes: %{}}}
    assert parse_xml_doc(File.read!("test/fixtures/fixture3.xml"))
      == {:error, "Expected `<?xml`, but was not found at line 1, column 0."}
    assert parse_xml_doc(File.read!("test/fixtures/fixture2.xml"))
      == %Doc{version: "1.0", encoding: "UTF-8", standalone: "yes",
              body: %Tag{attributes: %{}, name: "root", values: [
                "\n  ",
                %Tag{attributes: %{}, name: "child", values: [
                  "\n    ",
                  %Tag{attributes: %{}, name: "subchild", values: ["content"]},
                  "\n    ",
                  %Tag{attributes: %{}, name: "tag_without_content", values: nil},
                  "\n  "
                ]},
                "\n"
              ]}}
    assert parse_xml_doc(File.read!("test/fixtures/fixture1.xml"))
      == %Doc{version: "1.0", encoding: "UTF-8", standalone: "yes",
              body: %Tag{attributes: %{"orderid" => "889923",
                                       "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                                       "xsi:noNamespaceSchemaLocation" => "shiporder.xsd"},
                          name: "shiporder",
                          values: [
                "\n",
                %Tag{attributes: %{}, name: "orderperson", values: ["John Smith"]},
                "\n",
                %Tag{attributes: %{}, name: "shipto", values: [
                  "\n  ",
                  %Tag{attributes: %{}, name: "name", values: ["Ola Nordmann"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "address", values: ["Langgt 23"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "city", values: ["4000 Stavanger"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "country", values: ["Norway"]},
                  "\n"
                ]},
                "\n",
                %Tag{attributes: %{}, name: "item", values: [
                  "\n  ",
                  %Tag{attributes: %{}, name: "title", values: ["Empire Burlesque"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "note", values: ["Special Edition"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "quantity", values: ["1"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "price", values: ["10.90"]},
                  "\n"
                ]},
                "\n",
                %Tag{attributes: %{}, name: "item", values: [
                  "\n  ",
                  %Tag{attributes: %{}, name: "title", values: ["Hide your heart"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "quantity", values: ["1"]},
                  "\n  ",
                  %Tag{attributes: %{}, name: "price", values: ["9.90"]},
                  "\n"
                ]},
                "\n"
              ]}}

    assert parse_xml_doc(File.read!("test/fixtures/fixture4.xml"))
      == %XML.Doc{body: %XML.Tag{
                  attributes: %{
                    "name" => "StockQuote",
                    "targetNamespace" => "http://example.com/stockquote.wsdl",
                    "xmlns" => "http://schemas.xmlsoap.org/wsdl/",
                    "xmlns:soap" => "http://schemas.xmlsoap.org/wsdl/soap/",
                    "xmlns:tns" => "http://example.com/stockquote.wsdl",
                    "xmlns:xsd1" => "http://example.com/stockquote.xsd"
                  },
                  name: "definitions",
                  values: [
                    "\n\n    ",
                    %XML.Tag{
                      attributes: %{"name" => "SubscribeToQuotes"},
                      name: "message",
                      values: [
                        "\n        ",
                        %XML.Tag{
                          attributes: %{
                            "element" => "xsd1:SubscribeToQuotes",
                            "name" => "body"
                          },
                          name: "part",
                          values: nil
                        },
                        "\n        ",
                        %XML.Tag{
                          attributes: %{
                            "element" => "xsd1:SubscriptionHeader",
                            "name" => "subscribeheader"
                          },
                          name: "part",
                          values: nil
                        },
                        "\n    "
                      ]
                    },
                    "\n\n    ",
                    %XML.Tag{
                      attributes: %{"name" => "StockQuotePortType"},
                      name: "portType",
                      values: [
                        "\n        ",
                        %XML.Tag{
                          attributes: %{"name" => "SubscribeToQuotes"},
                          name: "operation",
                          values: [
                            "\n           ",
                            %XML.Tag{
                              attributes: %{"message" => "tns:SubscribeToQuotes"},
                              name: "input",
                              values: nil
                            },
                            "\n        "
                          ]
                        },
                        "\n    "
                      ]
                    },
                    "\n    ",
                    %XML.Tag{
                      attributes: %{},
                      name: "types",
                      values: [
                        "\n        ",
                        %XML.Tag{
                          attributes: %{
                            "targetNamespace" => "http://example.com/stockquote.xsd",
                            "xmlns" => "http://www.w3.org/2000/10/XMLSchema"
                          },
                          name: "schema",
                          values: [
                            "\n           ",
                            %XML.Tag{
                              attributes: %{"name" => "SubscribeToQuotes"},
                              name: "element",
                              values: [
                                "\n               ",
                                %XML.Tag{
                                  attributes: %{},
                                  name: "complexType",
                                  values: [
                                    "\n                   ",
                                    %XML.Tag{
                                      attributes: %{},
                                      name: "all",
                                      values: [
                                        "\n                       ",
                                        %XML.Tag{
                                          attributes: %{
                                            "name" => "tickerSymbol",
                                            "type" => "string"
                                          },
                                          name: "element",
                                          values: nil
                                        },
                                        "\n                   "
                                      ]
                                    },
                                    "\n               "
                                  ]
                                },
                                "\n           "
                              ]
                            },
                            "\n           ",
                            %XML.Tag{
                              attributes: %{
                                "name" => "SubscriptionHeader",
                                "type" => "uriReference"
                              },
                              name: "element",
                              values: nil
                            },
                            "\n        "
                          ]
                        },
                        "\n      "
                      ]
                    },
                    "\n    ",
                    %XML.Tag{
                      attributes: %{"name" => "StockQuoteService"},
                      name: "service",
                      values: [
                        "\n        ",
                        %XML.Tag{
                          attributes: %{
                            "binding" => "tns:StockQuoteSoap",
                            "name" => "StockQuotePort"
                          },
                          name: "port",
                          values: [
                            "\n           ",
                            %XML.Tag{
                              attributes: %{
                                "location" => "mailto:subscribe@example.com"
                              },
                              name: "soap:address",
                              values: nil
                            },
                            "\n        "
                          ]
                        },
                        "\n    "
                      ]
                    },
                    "\n\n"
                  ]
      },
      encoding: "",
      standalone: "yes",
      version: "1.0"
      }
  end

  test "parsing XML body" do
    # mismatched XML tags:
    assert parse_xml_body(File.read!("test/fixtures/fixture3.xml"))
      == {:error, "Expected at least one parser to succeed at line 1, column 0."}
    assert parse_xml_body("<xml>")
      == {:error, "Expected at least one parser to succeed at line 1, column 0."}
    assert parse_xml_body("<xml></xml>") == %Tag{attributes: %{}, name: "xml", values: []}
    assert parse_xml_body("<xml/>") == %Tag{attributes: %{}, name: "xml", values: nil}
    assert parse_xml_body("<xml><tag a=\"1\"/></xml>")
      == %Tag{attributes: %{}, name: "xml",
              values: [%Tag{attributes: %{"a" => "1"}, name: "tag", values: nil}]}
    assert parse_xml_body("<a>\n<b/>\n<c/>\n</a>")
      == %Tag{attributes: %{}, name: "a",
              values: [
                "\n",
                %Tag{name: "b", attributes: %{}, values: nil},
                "\n",
                %Tag{name: "c", attributes: %{}, values: nil},
                "\n",
              ]}
    assert parse_xml_body("<a>\n<b></b>\n<c>d</c>\n</a>")
      == %Tag{attributes: %{}, name: "a",
              values: [
                "\n",
                %Tag{name: "b", attributes: %{}, values: []},
                "\n",
                %Tag{name: "c", attributes: %{}, values: ["d"]},
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
        == %Tag{name: "tag1", attributes: %{}, values: nil}
    assert parse_tag_no_content("<tag2 a=\"b\"/>")
        == %Tag{name: "tag2", attributes: %{"a" => "b"}, values: nil}
    assert parse_tag_no_content("<tag3 a=\"b\" c=\"de\"/>")
        == %Tag{name: "tag3", attributes: %{"a" => "b", "c" => "de"}, values: nil}
  end

  test "parsing XML tags with content" do
    assert parse_tag_with_content("<tag1></tag1>")
        == %Tag{name: "tag1", attributes: %{}, values: []}
    assert parse_tag_with_content("<tag2 a=\"b\"   ></tag2>")
        == %Tag{name: "tag2", attributes: %{"a" => "b"}, values: []}
    assert parse_tag_with_content("<tag3 a=\"b\" c=\"de\">   a b    c   </tag3>")
        == %Tag{name: "tag3", attributes: %{"a" => "b", "c" => "de"},
                values: ["   a b    c   "]}
    assert parse_tag_with_content("<tag4 a=\"b\" c=\"de\"></tag5>")
        == {:error, xml_err("tag4", "tag5")}
    assert parse_tag_with_content("<tag6 a=\"b\" c=\"de\"><tag7/></tag6>")
        == %Tag{name: "tag6",
                attributes: %{"a" => "b", "c" => "de"},
                values: [%Tag{name: "tag7", attributes: %{}}]}
    assert parse_tag_with_content("<tag8 a=\"b\" c=\"de\"><tag9></tag9></tag8     >")
        == %Tag{name: "tag8",
                attributes: %{"a" => "b", "c" => "de"},
                values: [%Tag{name: "tag9", attributes: %{}, values: []}]}
    assert parse_tag_with_content("<tag10>\n <tag11/></tag10>")
      == %Tag{name: "tag10", attributes: %{},
              values: ["\n ", %Tag{name: "tag11", values: nil, attributes: %{}}]}
    assert parse_tag_with_content("<tag10>\n a<tag11/></tag10>")
      == %Tag{name: "tag10", attributes: %{},
              values: ["\n a", %Tag{name: "tag11", values: nil, attributes: %{}}]}
    assert parse_tag_with_content("<tag12><tag13/><tag14/></tag12>")
      == %Tag{name: "tag12", attributes: %{}, values: [
        %Tag{name: "tag13", attributes: %{}, values: nil},
        %Tag{name: "tag14", attributes: %{}, values: nil}
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
