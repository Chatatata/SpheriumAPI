defmodule Spherium.Endpoint do
  use Phoenix.Endpoint, otp_app: :spherium

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_spherium_key",
    signing_salt: "ku8kC4lJ"

  plug CORSPlug

  plug Spherium.Router
end
