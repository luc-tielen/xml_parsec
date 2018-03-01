defmodule XML.Attribute do
  @moduledoc """
  Module containing struct representing an XML attribute.
  """

  @type t :: %__MODULE__{
    key: String.t(),
    value: String.t()
  }

  defstruct [:key, :value]
end
