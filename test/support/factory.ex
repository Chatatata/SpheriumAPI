defmodule Spherium.Factory do
  use ExMachina.Ecto, repo: Spherium.Repo

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  def user_factory do
    %Spherium.User{
      username: sequence(:username, &"user#{&1}"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      password_digest: hashpwsalt("123456"),
      authentication_scheme: :insecure
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

  def passphrase_factory do
    %Spherium.Passphrase{
      user_id: build(:user).id,
      passkey: Spherium.Passkey.generate()
    }
  end

  def passphrase_invalidation_factory do
    %Spherium.PassphraseInvalidation{
      ip_addr: "#{:rand.uniform(256)}.#{:rand.uniform(256)}.#{:rand.uniform(256)}.#{:rand.uniform(256)}"
    }
  end

  def password_reset_factory do
    %Spherium.PasswordReset{
      user_id: build(:user).id
    }
  end

  def one_time_code_factory do
    %Spherium.OneTimeCode{
      user_id: build(:user).id,
      code: Spherium.Code.generate()
    }
  end

  def one_time_code_invalidation_factory do
    %Spherium.OneTimeCodeInvalidation{
      one_time_code_id: build(:one_time_code).id
    }
  end

  def insecure_authentication_handle_factory do
    %Spherium.InsecureAuthenticationHandle{
      passkey: Spherium.Passkey.generate(),
      user: build(:user)
    }
  end
end
