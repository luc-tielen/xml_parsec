defmodule XML.Parser do
  alias XML.Parser.Internal

  @moduledoc """
  Module containing functions for parsing XML documents.
  """

  @type xml :: String.t
  @type reason :: String.t | atom

  @doc """
  Function that parses an entire XML document (including XML prolog).
  """
  @spec parse_doc(xml) :: {:ok, %XML.Doc{}} | {:error, reason}
  def parse_doc(xml) do
    case Combine.parse(xml, Internal.xml_doc_parser()) do
      {:error, _} = err -> err
      [result] -> {:ok, result}
    end
  end

  @doc """
  Function that parses an entire XML document (without XML prolog).
  """
  @spec parse_xml(xml) :: {:ok, %XML.Tag{}} | {:error, reason}
  def parse_xml(xml) do
    case Combine.parse(xml, Internal.xml_body_parser()) do
      {:error, _} = err -> err
      [result] -> {:ok, result}
    end
  end
end

defmodule XML.Parser.Internal do
  use Combine, parsers: [:text]
  import XML.ParserHelpers
  alias XML.Doc
  alias XML.Tag

  @moduledoc """
  Module containing helper functions used internally by the XML.Parser module.
  These are heavily related to the internal parsing logic and can change a lot in structure.
  """

  @type parser :: Combine.Parser

  @doc """
  Creates a parser that can parse an entire XML document, including XML prolog.
  """
  @spec xml_doc_parser() :: parser
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

  @doc """
  Creates a parser that can parse the XML prolog.
  """
  @spec xml_header_parser() :: parser
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

  @doc """
  Creates a parser that can parse a top level XML tag.
  """
  @spec xml_body_parser() :: parser
  def xml_body_parser() do
    choice([tag_no_content_parser(), tag_with_content_parser()])
  end

  @doc false
  @spec tag_with_attrs() :: parser
  defp tag_with_attrs(), do: sequence([tag(), many(attribute())])

  @doc false
  @spec start_tag_parser() :: parser
  defp start_tag_parser(), do: between(char("<"), tag_with_attrs(), char(">"))

  @doc false
  @spec end_tag_parser() :: parser
  defp end_tag_parser(), do: between(string("</"), word_(), char(">"))

  @doc """
  Parses an XML tag with no inner contents (e.g. <tag a="1" b="2"/>).
  """
  @spec tag_no_content_parser :: parser
  def tag_no_content_parser() do
    between(char("<"), tag_with_attrs(), string("/>"))
    |> map(fn [tag, attributes] ->
      %Tag{name: tag, attributes: Enum.into(attributes, %{})}
    end)
  end

  @doc """
  Parses an XML tag with inner contents (e.g. <tag1 x="123"><tag2>contents</tag2></tag1>).
  """
  @spec tag_with_content_parser :: parser
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

  # NOTE: Laziness needed due to recursive nature of XML.
  @doc false
  @spec xml_nested_parser() :: parser
  defp xml_nested_parser(), do: lazy(fn -> xml_body_parser() end)

  @doc """
  Parses a string in an XML document.
  """
  @spec string_parser() :: parser
  def string_parser() do
    choice([xml_char(), ignore(comment_parser())])
    |> many1()
    |> map(&Enum.join/1)
  end

  @doc false
  @spec xml_char() :: parser
  defp xml_char(), do: char() |> none_of(["<", ">", "&"])

  @doc false
  @spec xml_name() :: parser
  defp xml_name(), do: word_of(~r/[\w._1-9\-:]+/)

  @doc false
  @spec tag() :: parser
  defp tag(), do: lexeme(xml_name()) |> label("tag name")

  @doc """
  Parses attribute (key / value) pair used in the XML prolog.
  """
  @spec header_attribute() :: parser
  def header_attribute() do
    sequence([ lexeme(header_attr_key()),
               ignore(char_("=")),
               lexeme(attr_value() |> between_quotes())
             ])
    |> map(&List.to_tuple/1)
  end

  @doc """
  Parses an attribute (key + value) inside an XML tag.
  """
  @spec attribute() :: parser
  def attribute() do
    sequence([ lexeme(attr_key()),
               ignore(char_("=")),
               lexeme(attr_value() |> between_quotes())
             ])
    |> map(&List.to_tuple/1)
  end

  @doc false
  @spec header_attr_key() :: parser
  defp header_attr_key() do
    word()
    |> one_of(["version", "encoding", "standalone"])
    |> label("header attribute key")
  end

  @doc false
  @spec attr_key() :: parser
  defp attr_key(), do: xml_name() |> label("attribute key")

  @doc false
  @spec attr_value() :: parser
  defp attr_value() do
    char()
    |> none_of(["\""])
    |> many()
    |> label("attribute value")
    |> map(&Enum.join/1)
  end

  @doc """
  Parses an XML comment.
  """
  @spec comment_parser() :: parser
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

  @doc false
  @spec between_quotes(parser) :: parser
  defp between_quotes(parser), do: between(char("\""), parser, char("\""))

  @doc false
  @spec word_() :: parser
  defp word_(), do: lexeme(word())

  @doc false
  @spec string_(String.t) :: parser
  defp string_(s), do: lexeme(string(s))

  @doc false
  @spec char_(String.t) :: parser
  defp char_(c), do: lexeme(char(c))

  @doc false
  @spec lexeme(parser) :: parser
  defp lexeme(parser), do: pair_left(parser, skip_many(whitespace()))

  @doc false
  @spec whitespace() :: parser
  defp whitespace(), do: choice([space(), newline()])
end
