defmodule XML.ParserHelpers do
  use Combine.Helpers
  alias Combine.ParserState

  defparser lazy(%ParserState{status: :ok} = state, parser_fn) do
    (parser_fn.()).(state)
  end
end
