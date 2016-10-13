defmodule Spherium.ProfileImageControllerPolicyTest do
  use Spherium.PolicyCase

  alias Spherium.Factory
  alias Spherium.ProfileImageControllerPolicy

  for element <- [:show, :delete] do
    @element element
    route_string = Atom.to_string(@element)

    test "passes if user wants to access own image with action " <> route_string, %{conn: conn} do
      assert Kernel.apply(ProfileImageControllerPolicy, @element, [conn, %{"user_id" => Integer.to_string(conn.assigns[:user].id)}, :self])
    end

    test "fails if user wants to access others image with action " <> route_string, %{conn: conn} do
      other_user = Factory.insert(:user)

      refute Kernel.apply(ProfileImageControllerPolicy, @element, [conn, %{"user_id" => Integer.to_string(other_user.id)}, :self])
    end

    test "fails if user wants to access non-existing person's image with action " <> route_string, %{conn: conn} do
      refute Kernel.apply(ProfileImageControllerPolicy, @element, [conn, %{"user_id" => Integer.to_string(-1)}, :self])
    end
  end

  for element <- [:create, :update] do
    @element element
    route_string = Atom.to_string(@element)

    test "passes if user wants to access own image with action " <> route_string, %{conn: conn} do
      user = conn.assigns[:user]

      assert Kernel.apply(ProfileImageControllerPolicy, @element, [conn, %{"user_id" => Integer.to_string(user.id),
                                                                           "profile_image" => ""
                                                                           }, :self])
    end

    test "fails if user wants to access own image with action " <> route_string, %{conn: conn} do
      other_user = Factory.insert(:user)

      refute Kernel.apply(ProfileImageControllerPolicy, @element, [conn, %{"user_id" => Integer.to_string(other_user.id),
                                                                           "profile_image" => ""
                                                                           }, :self])
    end

    test "fails if user wants to access non-existing person's image with action " <> route_string, %{conn: conn} do
      refute Kernel.apply(ProfileImageControllerPolicy, @element, [conn, %{"user_id" => Integer.to_string(-1),
                                                                           "profile_image" => ""
                                                                           }, :self])
    end
  end
end
