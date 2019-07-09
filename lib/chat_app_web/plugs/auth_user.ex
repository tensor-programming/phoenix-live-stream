defmodule ChatAppWeb.Plugs.AuthUser do
  import Plug.Conn
  import Phoenix.Controller

  alias ChatAppWeb.Router.Helpers, as: Routes

  def init(_) do
  end

  def call(conn, _params) do
    if conn.assigns.signed_in? do
      conn
    else
      conn
      |> put_flash(:error, "You need to be signed in")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end

  def can_access?(user, room) do
    user && user.id == room.user_id
  end
end
