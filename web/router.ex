defmodule SpheriumWebService.Router do
  use SpheriumWebService.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SpheriumWebService do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit] do
      resources "/image", ProfileImageController, except: [:new, :edit], singleton: true
      resources "/password", UserPasswordController, only: [:update], singleton: true
      resources "/permission_set", UserPermissionSetController, only: [:show, :update, :delete], singleton: true
    end

    scope "/auth" do
      resources "/attempts", AuthAttemptController, only: [:index, :show, :create]

      resources "/permissions", PermissionController, only: [:index, :show, :update]
      resources "/permission_sets", PermissionSetController, except: [:new, :edit]
      resources "/permission_set_grants", PermissionSetGrantController, except: [:new, :edit]
    end

    resources "/subscribers", SubscriberController, except: [:new, :edit]

    resources "/publishers", PublisherController, except: [:new, :edit]
    resources "/questions", QuestionController, except: [:new, :edit]

    # get "/questions/:id", QuestionController, :show
  end
end
