defmodule PopoWeb.PopoChannel do
  use PopoWeb, :channel

  alias Popo.Messages

  intercept ["shout", "add_friend", "new_friends"]

  def join("popo:lobby", payload, socket) do
    if authorized?(payload) do
      IO.puts ">>>>>>>>>>>join channel"
      # PopoWeb.Endpoint.subscribe("popo:" <> _id)
      IO.inspect payload["id"]
      IO.inspect payload
      socket = socket
        |> assign(:user, payload["id"])
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (popo:lobby).
  def handle_in("shout", payload, socket) do
    IO.puts "popo channel check========="
    IO.inspect socket
    IO.inspect payload
    %{"id" => id, "to" => target, "message" => msg, "name" => name} = payload
    {int_id, _} = Integer.parse(id)
    {int_target, _} = Integer.parse(target)
    time = NaiveDateTime.utc_now()
    Messages.create_message(%{from: int_id, to: int_target, content: msg, time: time})
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("msg_history", payload, socket) do
    IO.puts "popo get msg history=========="
    %{"from" => from, "to" => to} = payload
    {int_from, _} = Integer.parse(from)
    {int_to, _} = Integer.parse(to)
    msg_history = Messages.msg_history(int_from, int_to) # Messages.get_msg_history(from, to)
    msg_history = Enum.map(msg_history, fn m -> 
      %{from: Popo.Users.get_user_name_by_id(m.from).name, time: NaiveDateTime.to_string(m.time), content: m.content}
    end)
    reply = %{to: Popo.Users.get_user_name_by_id(int_to).name, msg_list: msg_history}
    IO.inspect reply
    push socket, "msg_history", reply
    {:noreply, socket}
  end

  def handle_in("add_friend", payload, socket) do
    IO.puts "popo add friend ============"
    %{"from" => from, "to" => to} = payload
    {int_from, _} = Integer.parse(from)
    {int_to, _} = Integer.parse(to)
    request = %{from_id: from, from_name: Popo.Users.get_user_name_by_id(from).name, to: to}
    broadcast socket, "add_friend", request
  end

  def handle_in("new_friends", payload, socket) do
    if (payload.accept) do
      # add to database: new friends 1-2 & 2-1
    end
    broacast socket, "new_friends", payload
  end

  def handle_out("shout", payload, socket) do
    IO.puts ">>>>>>> handle out chat"
    IO.puts "socket"
    IO.inspect socket.assigns
    IO.puts "payload"
    IO.inspect payload
    
    if socket.assigns[:user] == payload["to"] || socket.assigns[:user] == payload["id"] do
      push socket, "shout", payload
    end
    {:noreply, socket}
  end

  def handle_out("add_friend", payload, socket) do
    IO.puts ">>>>>>>> handle out add friend"
    IO.puts "payload"
    IO.inspect payload

    if socket.assigns[:user] == payload["to"] do
      push socket, "add_friend", payload
    end
    {:noreply, socket}
  end

  def handle_out("new_friends", payload, socket) do
    # send request result back
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
