defmodule Spherium.InsufficientScopeError do
  defexception plug_status: 401, message: "user has insufficient scope", conn: nil, router: nil

  def exception(opts) do
    conn   = Keyword.fetch!(opts, :conn)
    router = Keyword.fetch!(opts, :router)

    %Spherium.InsufficientScopeError{message: "user has insufficient scope",
                            conn: conn,
                            router: router}
  end
end
