defmodule XML.Tag do
  @moduledoc """
  Module containing struct representing an example tag.
  """

  @type t :: %__MODULE__{
    name: String.t(),
    attributes: %{},
    value: [%__MODULE__{} | String.t()] | nil
  }

  defstruct [:name, :attributes, :value]
end
