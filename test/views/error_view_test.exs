defmodule Spherium.ErrorViewTest do
  use Spherium.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(Spherium.ErrorView, "404.json", []) ==
           %{errors: %{name: "Not Found", detail: "Requested property does not exist."}}
  end

  test "render 500.json" do
    assert render(Spherium.ErrorView, "500.json", []) ==
           %{errors: %{name: "Internal Server Error", detail: "Somethings went wrong in the server, please contact with administrator."}}
  end

  test "render any other" do
    assert render(Spherium.ErrorView, "505.json", []) ==
           %{errors: %{name: "Internal Server Error", detail: "Somethings went wrong in the server, please contact with administrator."}}
  end
end
