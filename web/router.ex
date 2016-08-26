defmodule SpheriumWebService.Router do
  use SpheriumWebService.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SpheriumWebService do
    pipe_through :api
    
    resources "/users", UserController, except: [:new, :edit]
    resources "/subscribers", SubscriberController, except: [:new, :edit]
  end
end
