defmodule SpheriumWebService.ErrorViewTest do
  use SpheriumWebService.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(SpheriumWebService.ErrorView, "404.json", []) ==
           %{errors: %{name: "Not Found", detail: "Requested property does not exist."}}
  end

  test "render 500.json" do
    assert render(SpheriumWebService.ErrorView, "500.json", []) ==
           %{errors: %{name: "Internal Server Error", detail: "Somethings went wrong in the server, please contact with administrator."}}
  end

  test "render any other" do
    assert render(SpheriumWebService.ErrorView, "505.json", []) ==
           %{errors: %{name: "Internal Server Error", detail: "Somethings went wrong in the server, please contact with administrator."}}
  end
end
