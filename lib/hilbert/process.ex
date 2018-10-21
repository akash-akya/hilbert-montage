defmodule Hilbert.Processor do
  alias Hilbert.Mapper
  alias Hilbert.Montage
  alias Hilbert.Ffmpeg
  alias Hilbert.Utils
  @resolution 64
  @bar_count 500

  def process([video, output]) do
    video = abs_path(video)
    temp_dir = create_temp()

    square_frames_count = @resolution * @resolution

    Utils.log("Creating frames")
    :ok = Ffmpeg.create_frames(video, square_frames_count, @bar_count, temp_dir)

    Utils.log("Creating montage")

    Utils.measure("creating hilbert montage", fn ->
      output = abs_path("./#{output}_hilbert.jpg")

      :ok =
        Mapper.hilbert_sequence(@resolution)
        |> Enum.map(&"square_#{&1}.bmp")
        |> Montage.create(output, temp_dir)
    end)

    Utils.measure("creating normal montage", fn ->
      output = abs_path("./#{output}_normal.jpg")

      :ok =
        Mapper.natural_sequence(@resolution * @resolution)
        |> Enum.map(&"square_#{&1}.bmp")
        |> Montage.create(output, temp_dir)
    end)

    Utils.measure("creating barcode montage", fn ->
      output = abs_path("./#{output}_bar.jpg")

      :ok =
        Mapper.natural_sequence(@bar_count)
        |> Enum.map(&"bar_#{&1}.bmp")
        |> Montage.create_bar_montage(output, temp_dir)
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

  defp delete_temp(dir), do: File.rm_rf!(dir)

  def abs_path(path), do: Path.expand(path) |> Path.absname()
end
