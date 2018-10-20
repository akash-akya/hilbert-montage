defmodule Hilbert do
  alias Hilbert.Processor

  def main(args \\ []) do
    # IO.inspect(args)
    Processor.process(args)
  end
end
