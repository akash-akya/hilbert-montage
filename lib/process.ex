defmodule Hilbert.Processor do
  alias Hilbert.Mapper
  alias Hilbert.Montage
  alias Hilbert.Ffmpeg
  @temp_dir Path.expand("/tmp/frames/") |> Path.absname()

  def process([video, output]) do
    video = abs_path(video)
    output = abs_path(output)

    Ffmpeg.create_frames(video, 4096, @temp_dir)

    :ok =
      Mapper.map(8)
      |> Enum.map(&String.pad_leading("#{&1}", 4, "0"))
      |> Enum.map(&"#{&1}.jpg")
      |> Montage.create(abs_path(output), @temp_dir)
  end

  def abs_path(path) do
    Path.expand(path) |> Path.absname()
  end
end
