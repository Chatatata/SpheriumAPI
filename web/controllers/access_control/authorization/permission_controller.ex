defmodule Spherium.PermissionController do
  @moduledoc """
  Handles permission endpoints.
  """
  use Spherium.Web, :controller

  alias Spherium.Permission

  plug :authenticate_user
  plug :authorize_user

  def index(conn, _params) do
    permissions = Repo.all(Permission)

    render(conn, "index.json", permissions: permissions)
  end

  def show(conn, %{"id" => id}) do
    permission = Repo.get!(Permission, id)

    render(conn, "show.json", permission: permission)
  end
end
