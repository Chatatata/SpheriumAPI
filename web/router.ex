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
    
    resources "/subscribers", SubscriberController, except: [:new, :edit]
    
    resources "/publishers", PublisherController, except: [:new, :edit] do
      resources "/questions", QuestionController, except: [:new, :edit, :show]
    end
    
    get "/questions/:id", QuestionController, :show
  end
end
