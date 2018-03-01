defmodule XML.Tag do
  @moduledoc """
  Module containing struct representing an example tag.
  """

  @type t :: %__MODULE__{
    name: String.t(),
    attributes: [XML.Attribute.t()],
    contents: %__MODULE__{} | String.t() | nil
  }

  defstruct [:name, :attributes, :contents]
end
