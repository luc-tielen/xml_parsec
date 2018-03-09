defmodule XML.Parser do
  use Combine, parsers: [:text]
  import XML.ParserHelpers
  alias XML.Doc
  alias XML.Tag


  def parse(xml), do: Combine.parse(xml, xml_doc_parser())

  def xml_doc_parser() do
    sequence([skip_many(whitespace()),
              lexeme(xml_header_parser()),
              xml_body_parser()
             ])
    |> map(fn [header, body] ->
      %Doc{
        version: Map.get(header, "version", ""),
        encoding: Map.get(header, "encoding", ""),
        standalone: Map.get(header, "standalone", "yes"),
        body: body
      }
    end)
  end

  def xml_header_parser() do
    between(string_("<?xml"), many(header_attribute()), string_("?>"))
    |> map(fn attributes ->
      attr_map = Enum.into(attributes, %{})
      if Map.has_key?(attr_map, "version") do
        attr_map
      else
        {:error, "Expected `version` attribute in XML header!"}
      end
    end)
  end

  def xml_body_parser() do
    choice([ tag_no_content_parser(), tag_with_content_parser()])
  end

  defp tag_with_attrs(), do: sequence([tag(), many(attribute())])

  defp start_tag_parser(), do: between(char("<"), tag_with_attrs(), char(">"))
  defp end_tag_parser(), do: between(string("</"), word_(), char(">"))

  def tag_no_content_parser() do
    between(char("<"), tag_with_attrs(), string("/>"))
    |> map(fn [tag, attributes] ->
      %Tag{name: tag, attributes: Enum.into(attributes, %{})}
    end)
  end

  def tag_with_content_parser() do
    contents_parser = many(choice([xml_nested_parser(), string_parser()]))
    sequence([start_tag_parser(),
              contents_parser,
              end_tag_parser()
             ])
    |> map(fn [[start_tag, attributes], values, end_tag] ->
      case start_tag do
        ^end_tag ->
            %Tag{name: start_tag,
                 attributes: Enum.into(attributes, %{}),
                 values: Enum.filter(values, fn val -> val != "" end)
            }
        _ -> {:error, "XML tags do not line up! Start tag: #{start_tag}, end tag: #{end_tag}."}
      end
    end)
  end

  # Laziness needed due to recursive nature of XML.
  defp xml_nested_parser(), do: lazy(fn -> xml_body_parser() end)

  def string_parser() do
    choice([xml_char(), ignore(comment_parser())])
    |> many1()
    |> map(&Enum.join/1)
  end

  defp xml_char(), do: char() |> none_of(["<", ">", "&"])

  defp xml_name(), do: word_of(~r/[\w._1-9\-:]+/)

  defp tag(), do: lexeme(xml_name()) |> label("tag name")

  def header_attribute() do
    sequence([ lexeme(header_attr_key()),
               ignore(char_("=")),
               lexeme(attr_value() |> between_quotes())
             ])
    |> map(&List.to_tuple/1)
  end

  def attribute() do
    sequence([ lexeme(attr_key()),
               ignore(char_("=")),
               lexeme(attr_value() |> between_quotes())
             ])
    |> map(&List.to_tuple/1)
  end

  defp header_attr_key() do
    word()
    |> one_of(["version", "encoding", "standalone"])
    |> label("header attribute key")
  end

  defp attr_key(), do: xml_name() |> label("attribute key")

  defp attr_value() do
    char()
    |> none_of(["\""])
    |> many()
    |> label("attribute value")
    |> map(&Enum.join/1)
  end

  def comment_parser() do
    # NOTE: weird construction since no way to create 'nothing' parser?
    close_comment = char("-") |> followed_by(string("->"))
    comment = close_comment
              |> if_not(xml_char())
              |> many()
              |> label("comment")
    between(string("<!--"), comment, string("-->"))
    |> map(fn results -> results |> Enum.into("") end)
  end

  defp between_quotes(parser), do: between(char("\""), parser, char("\""))

  defp word_(), do: lexeme(word())

  defp string_(s), do: lexeme(string(s))

  defp char_(c), do: lexeme(char(c))

  defp lexeme(parser), do: pair_left(parser, skip_many(whitespace()))

  defp whitespace(), do: choice([space(), newline()])
end
