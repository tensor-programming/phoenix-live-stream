defmodule ChatAppWeb.RegistrationController do
  use ChatAppWeb, :controller

  alias ChatApp.Accounts

  def new(conn, _) do
    render(conn, "new.html", changeset: conn)
  end

  def create(conn, %{"registration" => registration_params}) do
    case Accounts.register(registration_params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "You've Signed up and Signed In!")
        |> redirect(to: Routes.room_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
