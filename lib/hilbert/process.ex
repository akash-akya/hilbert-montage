defmodule Hilbert.Processor do
  alias Hilbert.Mapper
  alias Hilbert.Montage
  alias Hilbert.Ffmpeg
  alias Hilbert.Utils
  @resolution 64

  def process([video, output]) do
    video = abs_path(video)
    temp_dir = create_temp()

    frames_count = @resolution * @resolution

    Utils.log("Creating frames")
    Ffmpeg.create_frames(video, frames_count, temp_dir)

    Utils.log("Creating montage")

    Utils.measure("creating hilbert montage", fn ->
      output = abs_path("./#{output}_hilbert.jpg")

      :ok =
        Mapper.hilbert_sequence(@resolution)
        |> Enum.map(&normalize(&1))
        |> Montage.create(output, temp_dir)
    end)

    Utils.measure("creating normal montage", fn ->
      output = abs_path("./#{output}_normal.jpg")

      :ok =
        Mapper.normal_sequence(@resolution)
        |> Enum.map(&normalize(&1))
        |> Montage.create(output, temp_dir)
    end)

    delete_temp(temp_dir)

    Utils.log("Montage files created")
  end

  defp create_temp() do
    dir = (System.tmp_dir() <> "/hilbert/") |> abs_path

    if !File.dir?(dir) do
      :ok = File.mkdir!(dir)
    end

    dir
  end

  defp delete_temp(dir) do
    _removed = File.rm_rf!(dir)
  end

  defp normalize(num) do
    "#{num}.jpg"
    # String.pad_leading("#{num}", 4, "0") <> ".jpg"
  end

  def abs_path(path), do: Path.expand(path) |> Path.absname()
end
