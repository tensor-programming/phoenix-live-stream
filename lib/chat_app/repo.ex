defmodule ChatApp.Repo do
  use Ecto.Repo,
    otp_app: :chat_app,
    adapter: Ecto.Adapters.Postgres
end
