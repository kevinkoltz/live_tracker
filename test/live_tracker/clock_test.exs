defmodule LiveTracker.ClockTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Ecto.UUID
  alias LiveTracker.Clock

  def generate_song_id(_context) do
    song_id = UUID.generate()

    {:ok, song_id: song_id}
  end

  describe "initial state" do
    setup :generate_song_id

    test "sets initial clock values", context do
      {:ok, pid} = Clock.start_link(context.song_id)
      state = :sys.get_state(pid)

      assert state.playing == false
      assert state.song_position == 0
      assert state.timer == nil
    end
  end

  describe "start" do
    setup :generate_song_id

    test "starts a timer", context do
      {:ok, pid} = Clock.start_link(context.song_id, bpm: 20_000)
      Clock.play(context.song_id)

      :timer.sleep(100)

      state = :sys.get_state(pid)

      assert state.playing == true
      assert state.song_position > 0
      refute state.timer == nil
    end
  end

  describe "stop" do
    setup :generate_song_id

    test "stops a timer, but does not reset position", context do
      {:ok, pid} = Clock.start_link(context.song_id, playing: true, song_position: 100)
      Clock.stop(context.song_id)

      state = :sys.get_state(pid)

      assert state.playing == false
      assert state.song_position == 100
      assert state.timer == nil
    end

    test "resets position when stopped twice", context do
      {:ok, pid} = Clock.start_link(context.song_id, playing: true, song_position: 100)
      Clock.stop(context.song_id)
      Clock.stop(context.song_id)

      state = :sys.get_state(pid)

      assert state.song_position == 0
    end
  end

  describe "update_tempo" do
    setup :generate_song_id

    test "updates bpm", context do
      {:ok, pid} = Clock.start_link(context.song_id, bpm: 20_000)
      Clock.play(context.song_id)
      state = :sys.get_state(pid)

      assert state.bpm == 20_000

      Clock.update_tempo(context.song_id, 20_001)
      state = :sys.get_state(pid)

      assert state.bpm == 20_001
    end
  end
end
