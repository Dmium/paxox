defmodule Server do
  require Logger

  def accept(port) do
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
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    serve(client)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    read_line(socket)
  end

  defp read_line(socket) do
    {x, data} = :gen_tcp.recv(socket, 0)
    write_line(x, data, socket)
  end

  defp write_line(:ok, line, socket) do
    IO.puts(line)
    :gen_tcp.send(socket, line)
    serve(socket)
  end

  defp write_line(:error, data, _) do
    IO.puts(data)
    :ended
  end
end
Server.accept(25567)
