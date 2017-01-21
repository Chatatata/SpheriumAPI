defmodule Spherium.InsufficientScopeError do
  defexception plug_status: 401,
               message: "user has insufficient scope"
end
