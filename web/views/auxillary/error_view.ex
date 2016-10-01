defmodule Spherium.ErrorView do
  use Spherium.Web, :view

  def render("404.json", _assigns) do
    %{errors: %{name: "Not Found", detail: "Requested property does not exist."}}
  end

  def render("500.json", _assigns) do
    %{errors: %{name: "Internal Server Error", detail: "Somethings went wrong in the server, please contact with administrator."}}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end
end
