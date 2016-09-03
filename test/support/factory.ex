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
      user: insert(:user)
    }
  end
  
  def publisher_factory do
    %SpheriumWebService.Publisher{
      name: "Test publisher",
      image: "some test data",
      description: "Test publisher's description...",
      user: insert(:user)
    }
  end
  
  def question_factory do
    %SpheriumWebService.Question{
      user: insert(:user),
      publisher: insert(:publisher)
    }
  end
end