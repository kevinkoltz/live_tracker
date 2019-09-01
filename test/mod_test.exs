defmodule ModTest do
  @moduledoc false
  use ExUnit.Case, async: true

  describe "parse" do
    @tag :skip
    test "song name" do
      file = "assets/static/mods/PRODIGY4.MOD"
      {:ok, data} = File.read(file)
      assert %{song_name: song_name} = Mod.parse(data)
      assert song_name == "hello"
    end
  end
end
