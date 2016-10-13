defmodule Spherium.UserControllerPolicyTests do
  use Spherium.PolicyCase

  alias Spherium.Factory
  alias Spherium.UserControllerPolicy

  for element <- [:show, :update, :delete] do
    @element element
    route_string = Atom.to_string(@element)

    test "passes if user wants to access its own information with self to " <> route_string, %{conn: conn} do
      user = conn.assigns[:user]

      assert Kernel.apply(UserControllerPolicy, @element, [conn, %{"id" => Integer.to_string(user.id)}, :self])
    end

    test "fails if user wants to access its others information with self to " <> route_string, %{conn: conn} do
      other_user = Factory.insert(:user)

      refute Kernel.apply(UserControllerPolicy, @element, [conn, %{"id" => Integer.to_string(other_user.id)}, :self])
    end

    test "fails if user wants to access not available entity with self to " <> route_string, %{conn: conn} do
      refute Kernel.apply(UserControllerPolicy, @element, [conn, %{"id" => Integer.to_string(-1)}, :self])
    end
  end
end
