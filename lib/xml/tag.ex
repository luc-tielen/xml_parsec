defmodule XML.Tag do
  import Lens

  @moduledoc """
  Module containing struct representing an example tag.
  """

  @type t :: %__MODULE__{
    name: String.t(),
    attributes: %{},
    values: [%__MODULE__{} | String.t()] | nil
  }

  deflenses [:name, :attributes, :values]
end
