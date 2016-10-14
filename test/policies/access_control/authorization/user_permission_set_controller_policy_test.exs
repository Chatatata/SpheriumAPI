defmodule Spherium.UserPermissionSetControllerPolicyTest do
  use Spherium.PolicyCase

  alias Spherium.Factory
  alias Spherium.UserPermissionSetControllerPolicy

  test "user wants to access his/her own permission set", %{conn: conn} do
    user = conn.assigns[:user]

    assert UserPermissionSetControllerPolicy.show(conn, %{"user_id" => Integer.to_string(user.id)}, :self)
  end

  test "user wants to access someones permission set", %{conn: conn} do
    other_user = Factory.insert(:user)

    refute UserPermissionSetControllerPolicy.show(conn, %{"user_id" => Integer.to_string(other_user.id)}, :self)
  end
end
