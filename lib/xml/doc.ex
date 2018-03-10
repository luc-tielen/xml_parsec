defmodule XML.Doc do
  alias XML.Tag
  import Lens

  @moduledoc """
  Module containing struct representing a complete XML document.
  """

  @type t :: %__MODULE__{
    version: String.t(),
    encoding: String.t(),
    standalone: true | false,
    body: %Tag{}
  }

  deflenses [:version, :encoding, :standalone, :body]
end
