defmodule XML.ParserHelpers do
  use Combine.Helpers
  alias Combine.ParserState

  @moduledoc """
  Helper module when working with parser combinators.
  """

  defparser lazy(%ParserState{status: :ok} = state, parser_fn) do
    (parser_fn.()).(state)
  end
end
