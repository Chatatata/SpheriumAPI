defmodule SpheriumWebService.Router do
  use SpheriumWebService.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SpheriumWebService do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit] do
      resources "/image", ProfileImageController, except: [:new, :edit], singleton: true
    end

    scope "/auth" do
      resources "/attempts", AuthAttemptController, only: [:index, :show, :create]
    end

    resources "/subscribers", SubscriberController, except: [:new, :edit]

    resources "/publishers", PublisherController, except: [:new, :edit]
    resources "/questions", QuestionController, except: [:new, :edit]

    # get "/questions/:id", QuestionController, :show
  end
end
