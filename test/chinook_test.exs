defmodule ChinookTest do
  use ExUnit.Case
  doctest Chinook

  test "greets the world" do
    assert Chinook.hello() == :world
  end
end
