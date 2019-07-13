defmodule ChatAppWeb.RoomChannel do
  use ChatAppWeb, :channel

  alias ChatApp.Repo
  alias ChatApp.Accounts.User
  alias ChatAppWeb.Presence
  alias ChatApp.Talk.Message
  alias ChatApp.Talk

  def join("room:" <> room_id, _params, socket) do
    send(self(), :after_join)
    {:ok, %{messages: Talk.list_messages(room_id)}, assign(socket, :room_id, room_id)}
  end

  def handle_in("message:add", %{"message" => body}, socket) do
    room = Talk.get_room!(socket.assigns[:room_id])
    user = get_user(socket)

    case Talk.create_message(user, room, %{body: body}) do
      {:ok, message} ->
        message = Repo.preload(message, :user)
        message_template = %{body: message.body, user: %{username: message.user.username}}
        broadcast!(socket, "room:#{message.room_id}:new_message", message_template)
        {:reply, :ok, socket}

      {:error, _} ->
        {:reply, :error, socket}
    end
  end

  def handle_in("user:typing", %{"typing" => typing}, socket) do
    user = get_user(socket)

    {:ok, _} =
      Presence.update(socket, "user:#{user.id}", %{
        typing: typing,
        user_id: user.id,
        username: user.username
      })

    {:reply, :ok, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))

    user = get_user(socket)

    {:ok, _} =
      Presence.track(socket, "user:#{user.id}", %{
        typing: false,
        user_id: user.id,
        username: user.username
      })

    {:noreply, socket}
  end

  def get_user(socket) do
    Repo.get(User, socket.assigns[:current_user_id])
  end
end
