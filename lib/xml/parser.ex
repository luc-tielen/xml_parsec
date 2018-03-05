defmodule XML.Parser do
  use Combine, parsers: [:text]
  import XML.ParserHelpers
  alias XML.Tag


  # TODO parse XML header

  def parse(xml), do: Combine.parse(xml, xml_parser())

  def xml_parser() do
    lazy(fn ->  # Laziness needed due to recursive nature of XML.
      choice([ tag_no_content_parser(),
               tag_with_content_parser(),
               string_parser(),
             ])
    end)
  end

  def tag_no_content_parser() do
    tag_with_attrs = sequence([tag(), many(attribute())])
    between(char("<"), tag_with_attrs, string("/>"))
    |> map(fn [tag, attributes] ->
      %Tag{name: tag, attributes: Enum.into(attributes, %{})}
    end)
  end

  def tag_with_content_parser() do
    tag_with_attrs = sequence([tag(), many(attribute())])
    start_tag_parser = between(char("<"), tag_with_attrs, char(">"))
    contents_parser = xml_parser()
    end_tag_parser = between(string("</"), word_(), char(">"))

    sequence([start_tag_parser, contents_parser, end_tag_parser])
    |> map(fn [[start_tag, attributes], contents, end_tag] ->
      case start_tag do
        ^end_tag -> %Tag{name: start_tag,
                         attributes: Enum.into(attributes, %{}),
                         value: contents}
        _ -> {:error, "XML tags do not line up! Start tag: #{start_tag}, end tag: #{end_tag}."}
      end
    end)
  end

  def string_parser() do
    choice([xml_char(), ignore(comment_parser())])
    |> many()
    |> map(&Enum.join/1)
  end

  defp xml_char(), do: char() |> none_of(["<", ">", "&"])

  defp tag(), do: label(word_(), "tag name")

  def attribute() do
    sequence([ lexeme(attr_key()),
               ignore(char_("=")),
               lexeme(attr_value() |> between_quotes())
             ])
    |> map(&List.to_tuple/1)
  end

  defp attr_key(), do: label(word(), "attribute key")

  defp attr_value() do
    char()
    |> none_of(["\""])
    |> many
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

  defp between_quotes(parser) do
    between(char("\""), parser, char("\""))
  end

  defp word_(), do: lexeme(word())

  defp char_(c), do: lexeme(char(c))

  defp lexeme(parser), do: pair_left(parser, skip(spaces()))
end
