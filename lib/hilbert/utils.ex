defmodule Hilbert.Utils do
  def measure(str, callback) do
    {time, result} = :timer.tc(callback, [])
    msg(" Time took for #{str}: #{time / 1_000_000}s")
    result
  end

  def log(str) do
    IO.puts("\n====================================================")
    msg(str)
    IO.puts("====================================================")
  end

  def msg(str), do: IO.puts(" #{str}")
end
