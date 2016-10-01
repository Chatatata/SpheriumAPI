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
        resources "/password", UserPasswordController, only: [:update], singleton: true
        resources "/permission_set", UserPermissionSetController, only: [:show, :update, :delete], singleton: true
      end

      resources "/subscribers", SubscriberController, except: [:new, :edit]

      scope "/authentication" do
        resources "/passphrases", PassphraseController, only: [:create] do
          resources "/invalidate", PassphraseInvalidationController, only: [:create], singleton: true
        end
        resources "/tokens", TokenController, only: [:create], singleton: true
        resources "/attempts", AttemptController, only: [:index, :show]
      end

      scope "/authorization" do
        resources "/permissions", PermissionController, only: [:index, :show, :update]
        resources "/permission_sets", PermissionSetController, except: [:new, :edit]
        resources "/permission_set_grants", PermissionSetGrantController, only: [:index, :show]
      end
    end

    scope "/data" do
      resources "/publishers", PublisherController, except: [:new, :edit]
      resources "/questions", QuestionController, except: [:new, :edit]

      # get "/questions/:id", QuestionController, :show
    end
  end
end
