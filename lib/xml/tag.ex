defmodule XML.Tag do
  @moduledoc """
  Module containing struct representing an example tag.
  """

  @type t :: %__MODULE__{
    name: String.t(),
    attributes: %{},
    values: [%__MODULE__{} | String.t()] | nil
  }

  defstruct [:name, :attributes, :values]
end
