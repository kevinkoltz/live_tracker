defmodule Mod do
  # credo:disable-for-this-file
  @moduledoc """

  This is a work-in-progress.

  The Amiga MOD Format
  https://www.ocf.berkeley.edu/~eek/index.html/tiny_examples/ptmod/ap12.html

  There are two main parts to MOD files:

  - Music samples (up to 31, or 15 for old format)
  - Sequencing information for the how to play these samples

  See [mod_spec.txt](../mod_spec.txt) for more info.


  Protracker 1.1B Song/Module Format:
  -----------------------------------

  Offset  Bytes  Description
  ------  -----  -----------
    0     20    Songname. Remember to put trailing null bytes at the end...

  Information for sample 1-31:

  Offset  Bytes  Description
  ------  -----  -----------
    20     22    Samplename for sample 1. Pad with null bytes.
    42      2    Samplelength for sample 1. Stored as number of words.
                Multiply by two to get real sample length in bytes.
    44      1    Lower four bits are the finetune value, stored as a signed
                four bit number. The upper four bits are not used, and
                should be set to zero.
                Value:  Finetune:
                  0        0
                  1       +1
                  2       +2
                  3       +3
                  4       +4
                  5       +5
                  6       +6
                  7       +7
                  8       -8
                  9       -7
                  A       -6
                  B       -5
                  C       -4
                  D       -3
                  E       -2
                  F       -1

    45      1    Volume for sample 1. Range is $00-$40, or 0-64 decimal.
    46      2    Repeat point for sample 1. Stored as number of words offset
                from start of sample. Multiply by two to get offset in bytes.
    48      2    Repeat Length for sample 1. Stored as number of words in
                loop. Multiply by two to get replen in bytes.

  Information for the next 30 samples starts here. It's just like the info for
  sample 1.

  Offset  Bytes  Description
  ------  -----  -----------
    50     30    Sample 2...
    80     30    Sample 3...
    .
    .
    .
  890     30    Sample 30...
  920     30    Sample 31...

  Offset  Bytes  Description
  ------  -----  -----------
  950      1    Songlength. Range is 1-128.
  951      1    Well... this little byte here is set to 127, so that old
                trackers will search through all patterns when loading.
                Noisetracker uses this byte for restart, but we don't.
  952    128    Song positions 0-127. Each hold a number from 0-63 that
                tells the tracker what pattern to play at that position.
  1080      4    The four letters "M.K." - This is something Mahoney & Kaktus
                inserted when they increased the number of samples from
                15 to 31. If it's not there, the module/song uses 15 samples
                or the text has been removed to make the module harder to
                rip. Startrekker puts "FLT4" or "FLT8" there instead.

  Offset  Bytes  Description
  ------  -----  -----------
  1084    1024   Data for pattern 00.
    .
    .
    .
  xxxx  Number of patterns stored is equal to the highest patternnumber
        in the song position table (at offset 952-1079).

  Each note is stored as 4 bytes, and all four notes at each position in
  the pattern are stored after each other.

  00 -  chan1  chan2  chan3  chan4
  01 -  chan1  chan2  chan3  chan4
  02 -  chan1  chan2  chan3  chan4
  etc.

  Info for each note:

  _____byte 1_____   byte2_    _____byte 3_____   byte4_
  /                \ /      \  /                \ /      \
  0000          0000-00000000  0000          0000-00000000

  Upper four    12 bits for    Lower four    Effect command.
  bits of sam-  note period.   bits of sam-
  ple number.                  ple number.

  Periodtable for Tuning 0, Normal
    C-1 to B-1 : 856,808,762,720,678,640,604,570,538,508,480,453
    C-2 to B-2 : 428,404,381,360,339,320,302,285,269,254,240,226
    C-3 to B-3 : 214,202,190,180,170,160,151,143,135,127,120,113

  To determine what note to show, scan through the table until you find
  the same period as the one stored in byte 1-2. Use the index to look
  up in a notenames table.

  This is the data stored in a normal song. A packed song starts with the
  four letters "PACK", but i don't know how the song is packed: You can
  get the source code for the cruncher/decruncher from us if you need it,
  but I don't understand it; I've just ripped it from another tracker...

  --
  Mark J Cox -----
  Bradford, UK ---
  """
  defstruct song_name: nil, sample_info: []

  def load(filename \\ "assets/static/mods/PRODIGY4.MOD") do
    {:ok, data} = File.read(filename)

    # {data, %__MODULE__{}}
    # |> parse_song_name()

    parse(data)

    # |> parse_sample_info()
  end

  @doc """
  Offset  Bytes  Description
  ------  -----  -----------
    0     20    Songname. Remember to put trailing null bytes at the end...
  """
  def parse_song_name(
        {<<song_name::size(20), sample_name::size(22), sample_length::size(2),
           sample_tune::size(1), sample_volume::size(1), sample_repeat_point::size(2),
           sample_repeat_length::size(2), rest::bitstring>>, acc}
      ) do
    IO.inspect(song_name, label: "song_name")
    IO.inspect(sample_name, label: "sample_name")
    IO.inspect(sample_length, label: "sample_length")
    IO.inspect(sample_tune, label: "sample_tune")
    IO.inspect(sample_volume, label: "sample_volume")
    IO.inspect(sample_repeat_point, label: "sample_repeat_point")
    IO.inspect(sample_repeat_length, label: "sample_repeat_length")

    {rest, Map.put(acc, :song_name, song_name)}
  end

  @song_name_length 11
  @sample_info_length 31 * 30
  def parse(<<
        song_name::bytes-size(@song_name_length),
        sample_info::bytes-size(@sample_info_length),
        song_length::bytes-size(1),
        nothing::bytes-size(1),
        song_positions::bytes-size(128),
        inits::bytes-size(4),
        _rest::bitstring
      >>) do
    IO.inspect(song_name, label: "song_name")
    IO.inspect(song_length, label: "song_length")
    IO.inspect(nothing, label: "nothing")
    IO.inspect(song_positions, label: "song_positions")
    IO.inspect(inits, label: "inits")
    {:ok, _sample_info} = parse_sample_info(sample_info)
    song_name
  end

  # 31 samples (or 15 for older format), 30 bytes each
  defp parse_sample_info(data, samples \\ [])
  defp parse_sample_info(<<>>, samples), do: {:ok, samples}

  defp parse_sample_info(
         <<name::binary-size(22), length::binary-size(2), tune::signed-integer-size(4), _::4,
           volume::binary-size(1), repeat_point::binary-size(2), repeat_length::binary-size(2),
           rest::bitstring>>,
         acc
       ) do
    # IO.inspect(name, label: "name")
    # IO.inspect(length, label: "length")
    # IO.inspect(tune, label: "tune")
    # IO.inspect(volume, label: "volume")
    # IO.inspect(repeat_point, label: "repeat_point")
    # IO.inspect(repeat_length, label: "repeat_length")

    info = %{
      name: binary_trim(name),
      length: length,
      tune: tune,
      volume: volume,
      repeat_point: repeat_point,
      repeat_length: repeat_length
    }

    parse_sample_info(rest, [info | acc])
  end

  defp binary_trim(<<0, rest>>), do: binary_trim(rest)
  defp binary_trim(data), do: data

  @doc """
  Information for sample 1-31:

  Offset  Bytes  Description
  ------  -----  -----------
    20     22    Samplename for sample 1. Pad with null bytes.
    42      2    Samplelength for sample 1. Stored as number of words.
                Multiply by two to get real sample length in bytes.
    44      1    Lower four bits are the finetune value, stored as a signed
                four bit number. The upper four bits are not used, and
                should be set to zero. Value:  Finetune:
                  0        0
                  1       +1
                  2       +2
                  3       +3
                  4       +4
                  5       +5
                  6       +6
                  7       +7
                  8       -8
                  9       -7
                  A       -6
                  B       -5
                  C       -4
                  D       -3
                  E       -2
                  F       -1

    45      1    Volume for sample 1. Range is $00-$40, or 0-64 decimal.
    46      2    Repeat point for sample 1. Stored as number of words offset
                from start of sample. Multiply by two to get offset in bytes.
    48      2    Repeat Length for sample 1. Stored as number of words in
                loop. Multiply by two to get replen in bytes.

  Information for the next 30 samples starts here. It's just like the info for
  sample 1.

  Offset  Bytes  Description
  ------  -----  -----------
    50     30    Sample 2...
    80     30    Sample 3...
    .
    .
    .
  890     30    Sample 30...
  920     30    Sample 31...
  """

  # Offset  Bytes  Description
  # ------  -----  -----------
  # 950      1    Songlength. Range is 1-128.
  # 951      1    Well... this little byte here is set to 127, so that old
  #               trackers will search through all patterns when loading.
  #               Noisetracker uses this byte for restart, but we don't.
  # 952    128    Song positions 0-127. Each hold a number from 0-63 that
  #               tells the tracker what pattern to play at that position.
  # 1080      4    The four letters "M.K." - This is something Mahoney & Kaktus
  #               inserted when they increased the number of samples from
  #               15 to 31. If it's not there, the module/song uses 15 samples
  #               or the text has been removed to make the module harder to
  #               rip. Startrekker puts "FLT4" or "FLT8" there instead.

  # Offset  Bytes  Description
  # ------  -----  -----------
  # 1084    1024   Data for pattern 00.
  #   .
  #   .
  #   .
  # xxxx  Number of patterns stored is equal to the highest patternnumber
  #       in the song position table (at offset 952-1079).

  # Each note is stored as 4 bytes, and all four notes at each position in
  # the pattern are stored after each other.

  # 00 -  chan1  chan2  chan3  chan4
  # 01 -  chan1  chan2  chan3  chan4
  # 02 -  chan1  chan2  chan3  chan4
  # etc.

  # Info for each note:

  # _____byte 1_____   byte2_    _____byte 3_____   byte4_
  # /                \ /      \  /                \ /      \
  # 0000          0000-00000000  0000          0000-00000000

  # Upper four    12 bits for    Lower four    Effect command.
  # bits of sam-  note period.   bits of sam-
  # ple number.                  ple number.

  # Periodtable for Tuning 0, Normal
  #   C-1 to B-1 : 856,808,762,720,678,640,604,570,538,508,480,453
  #   C-2 to B-2 : 428,404,381,360,339,320,302,285,269,254,240,226
  #   C-3 to B-3 : 214,202,190,180,170,160,151,143,135,127,120,113

  # To determine what note to show, scan through the table until you find
  # the same period as the one stored in byte 1-2. Use the index to look
  # up in a notenames table.

  # This is the data stored in a normal song. A packed song starts with the
  # four letters "PACK", but i don't know how the song is packed: You can
  # get the source code for the cruncher/decruncher from us if you need it,
  # but I don't understand it; I've just ripped it from another tracker...

  # In a module, all the samples are stored right after the patterndata.
  # To determine where a sample starts and stops, you use the sampleinfo
  # structures in the beginning of the file (from offset 20). Take a look
  # at the mt_init routine in the playroutine, and you'll see just how it
  # is done.

  # Lars "ZAP" Hamre/Amiga Freelancers
  def void do
    IO.inspect(1, label: "1")
  end
end
