defmodule Spherium.PasswordControllerPolicyTest do
  use Spherium.PolicyCase

  alias Spherium.PasswordControllerPolicy
  alias Spherium.Factory

  test "user with all permission may change own password", %{conn: conn, user: user} do
    assert PasswordControllerPolicy.update(conn,
                                           %{"user_id" => user.id,
                                             "password" => "123456"},
                                           :self)
  end

  test "user with all permission cannot change others password", %{conn: conn} do
    user = Factory.insert(:user)

    refute PasswordControllerPolicy.update(conn,
                                           %{"user_id" => user.id,
                                             "password" => "123456"},
                                           :self)
  end

  @tag attach_to_one_permissions: true
  test "user with self permission may change own password", %{conn: conn, user: user} do
    assert PasswordControllerPolicy.update(conn,
                                           %{"user_id" => user.id,
                                             "password" => "123456"},
                                           :self)
  end

  @tag attach_to_one_permissions: true
  test "user with self permission cannot change others password", %{conn: conn} do
    user = Factory.insert(:user)

    refute PasswordControllerPolicy.update(conn,
                                           %{"user_id" => user.id,
                                             "password" => "123456"},
                                           :self)
  end
end
