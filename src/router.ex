defmodule Spherium.Router do
  use Spherium.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Spherium do
    pipe_through :api

    scope "/access_control" do
      resources "/users", UserController, except: [:new, :edit] do
        resources "/image", ProfileImageController, except: [:new, :edit], singleton: true
        resources "/permission_set", UserPermissionSetController, only: [:show, :update, :delete], singleton: true
        resources "/password", PasswordController, only: [:update], singleton: true do
          resources "/reset", PasswordResetController, only: [:index, :create]
        end
      end

      resources "/subscribers", SubscriberController, except: [:new, :edit]

      resources "/authentication", AuthenticationController, only: [:create], singleton: true do
        resources "/passphrases", PassphraseController, only: [:index, :show]
        resources "/passphrase_invalidations", PassphraseInvalidationController, only: [:create]
        resources "/tokens", TokenController, only: [:create], singleton: true
        resources "/attempts", AttemptController, only: [:index, :show]
      end

      scope "/authorization" do
        resources "/permissions", PermissionController, only: [:index, :show, :update]
        resources "/permission_sets", PermissionSetController, except: [:new, :edit]
        resources "/permission_set_grants", PermissionSetGrantController, only: [:index, :show]
      end
    end
  end
end
