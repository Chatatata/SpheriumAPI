defmodule SpheriumWebService.Router do
  use SpheriumWebService.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SpheriumWebService do
    pipe_through :api
    
    resources "/users", UserController, except: [:new, :edit] do
      get "/image", ProfileImageController, :show
      post "/image", ProfileImageController, :create
      put "/image", ProfileImageController, :update
      delete "/image", ProfileImageController, :delete
    end
    
    resources "/subscribers", SubscriberController, except: [:new, :edit]
    
    resources "/publishers", PublisherController, except: [:new, :edit] do
      resources "/questions", QuestionController, except: [:new, :edit, :show]
    end
    
    get "/questions", QuestionController, :show
  end
end
