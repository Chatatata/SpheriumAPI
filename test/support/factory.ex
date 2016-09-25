defmodule Spherium.Factory do
  use ExMachina.Ecto, repo: Spherium.Repo

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  def user_factory do
    %Spherium.User{
      username: sequence(:username, &"user#{&1}"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      password_digest: hashpwsalt("123456"),
      scope: ["admin"]
    }
  end

  def subscriber_factory do
    %Spherium.Subscriber{
      address: sequence(:email, &"email-#{&1}@example.com")
    }
  end

  def profile_image_factory do
    %Spherium.ProfileImage{
      data: "some test data",
      user: build(:user)
    }
  end

  def publisher_factory do
    %Spherium.Publisher{
      name: "Test publisher",
      image: "some test data",
      description: "Test publisher's description...",
      user: build(:user)
    }
  end

  def question_factory do
    %Spherium.Question{
      user: build(:user),
      publisher: build(:publisher)
    }
  end

  def attempt_factory do
    %Spherium.Attempt{
      ip_addr: "#{:rand.uniform(256)}.#{:rand.uniform(256)}.#{:rand.uniform(256)}.#{:rand.uniform(256)}",
      success: true,
      username: build(:user).username
    }
  end

  def permission_factory do
    %Spherium.Permission{
      required_grant_power: 10,
      controller_name: sequence(:name, &"Elixir.Spherium.ExampleController#{&1}"),
      controller_action: "index",
      type: "one"
    }
  end

  def permission_set_factory do
    %Spherium.PermissionSet{
      name: sequence(:permission_set_name, &"permission_set_#{&1}"),
      description: sequence(:permission_set_description, &"permission_set_desc#{&1}"),
      grant_power: 500
    }
  end

  def permission_set_grant_factory do
    %Spherium.PermissionSetGrant{
    }
  end
end
