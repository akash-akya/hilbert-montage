defmodule HilbertTest do
  use ExUnit.Case
  doctest Hilbert

  test "greets the world" do
    assert Hilbert.hello() == :world
  end
end
