defmodule Spherium.InsecureAuthenticationHandleView do
  use Spherium.Web, :view

  def render("show.json", %{insecure_authentication_handle: insecure_authentication_handle}) do
    %{data: render_one(insecure_authentication_handle,
                       Spherium.InsecureAuthenticationHandleView,
                       "insecure_authentication_handle.json")}
  end

  def render("insecure_authentication_handle.json",
             %{insecure_authentication_handle: insecure_authentication_handle}) do
    %{user_id: insecure_authentication_handle.user_id,
      passkey: insecure_authentication_handle.passkey}
  end
end
