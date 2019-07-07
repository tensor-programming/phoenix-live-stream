defmodule ChatApp.Talk do
  alias ChatApp.Repo
  alias ChatApp.Talk.Room

  def list_rooms do
    Repo.all(Room)
  end

  def change_room(%Room{} = room) do
    Room.changeset(room, %{})
  end

  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  def get_room!(id), do: Repo.get!(Room, id)

  def delete_room(%Room{} = room) do
    room |> Repo.delete()
  end
end
