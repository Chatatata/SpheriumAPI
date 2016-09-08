defmodule SpheriumWebService.Factory do
  use ExMachina.Ecto, repo: SpheriumWebService.Repo

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  def user_factory do
    %SpheriumWebService.User{
      username: sequence(:username, &"user#{&1}"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      password_digest: hashpwsalt("123456"),
      scope: ["admin"]
    }
  end

  def subscriber_factory do
    %SpheriumWebService.Subscriber{
      address: sequence(:email, &"email-#{&1}@example.com")
    }
  end

  def profile_image_factory do
    %SpheriumWebService.ProfileImage{
      data: "some test data",
      user: build(:user)
    }
  end

  def publisher_factory do
    %SpheriumWebService.Publisher{
      name: "Test publisher",
      image: "some test data",
      description: "Test publisher's description...",
      user: build(:user)
    }
  end

  def question_factory do
    %SpheriumWebService.Question{
      user: build(:user),
      publisher: build(:publisher)
    }
  end

  # def invalid_auth_attempt_factory do
  #   %SpheriumWebService.AuthAttempt{
  #     ip_addr: sequence(:ip_addr, &"#{&1}.#{&1}.#{&1}.#{&1}")
  #     username: sequence(:username, &"nonexisting#{&1}"),
  #     success: true
  #   }
  # end
  #
  def auth_attempt_factory do
    %SpheriumWebService.AuthAttempt{
      ip_addr: sequence(:ip_addr, &"#{&1}.#{&1}.#{&1}.#{&1}"),
      success: true,
      username: build(:user).username
    }
  end
end
