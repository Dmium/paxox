defmodule Organiser do
  require Logger

  def accept(port, clientno) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    #
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connections on port #{port}")
    # Must spawn in future
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket, orgpid) do
    {:ok, client} = :gen_tcp.accept(socket)
    spawn(Organiser, :serve, [client, orgpid])
    loop_acceptor(socket)
  end

  defp serve(socket, orgpid) do
    {x, data} = :gen_tcp.recv(socket, 0)
    ready_check(socket, orgpid, x, data)
  end

  defp ready_check(socket, orgpid, :ok, :ready) do
    send(orgpid, {:ready, self(), socket})
  end
end
Server.accept(25567)
