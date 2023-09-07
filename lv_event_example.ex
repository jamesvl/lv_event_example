Application.put_env(:sample, Example.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 5001],
  server: true,
  live_view: [signing_salt: "aaaaaaaa"],
  secret_key_base: String.duplicate("a", 64)
)

Mix.install([
  {:plug_cowboy, "~> 2.5"},
  {:jason, "~> 1.0"},
  {:phoenix, "~> 1.7.0"},
  {:phoenix_live_view, "~> 0.19.0"}
])

defmodule Example.ErrorView do
  def render(template, _), do: Phoenix.Controller.status_message_from_template(template)
end

defmodule Example.EventExampleLive do
  use Phoenix.LiveView, layout: {__MODULE__, :live}

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :is_yes_checked, false)}
  end

  defp phx_vsn, do: Application.spec(:phoenix, :vsn)
  defp lv_vsn, do: Application.spec(:phoenix_live_view, :vsn)

  def render("live.html", assigns) do
    ~H"""
    <script src={"https://cdn.jsdelivr.net/npm/phoenix@#{phx_vsn()}/priv/static/phoenix.min.js"}></script>
    <script src={"https://cdn.jsdelivr.net/npm/phoenix_live_view@#{lv_vsn()}/priv/static/phoenix_live_view.min.js"}></script>
    <script>
      let liveSocket = new window.LiveView.LiveSocket("/live", window.Phoenix.Socket)
      liveSocket.connect()
    </script>
    <style>
      * { font-size: 1.1em; }
    </style>
    <%= @inner_content %>
    """
  end

  def render(assigns) do
    ~H"""
      <p>In LiveView 0.19, using the keyboard to set focus on a radio button
        issues no click event.
    </p>
    <label>
      <input
        id="yes-radio"
        type="radio"
        name="radio-01"
        value="Yes"
        checked={@is_yes_checked}
        phx-update="ignore"
        phx-click="got-click"
        phx-focus="got-focus"
        phx-value-val="yep"
        phx-value-addl={[1, 2]}
      />
      Yes
    </label>

    <label>
      <input
        id="no-radio"
        type="radio"
        name="radio-01"
        value="No"
        checked={!@is_yes_checked}
        phx-update="ignore"
        phx-click="got-click"
        phx-focus="got-focus"
        phx-value-val="nope"
        phx-value-addl={[3, 4]}
      />
      No
    </label>
    """
  end

  def handle_event("got-focus", _params, socket) do
    # IO.inspect(params, label: "focus params")

    {:noreply, socket}
  end

  def handle_event("got-click", params, socket) do
    # IO.inspect(params, label: "click params")

    {:noreply, assign(socket, :is_yes_checked, params["val"] == "yep")}
  end
end

defmodule Example.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  scope "/", Example do
    pipe_through(:browser)

    live("/", EventExampleLive, :index)
  end
end

defmodule Example.Endpoint do
  use Phoenix.Endpoint, otp_app: :sample
  socket("/live", Phoenix.LiveView.Socket)
  plug(Example.Router)
end

{:ok, _} = Supervisor.start_link([Example.Endpoint], strategy: :one_for_one)
Process.sleep(:infinity)
