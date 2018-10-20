defmodule Hilbert.Ffmpeg do
  alias Hilbert.Utils
  @ffmpeg "ffmpeg"

  def create_frames(file, count, dir) do
    duration = video_duration(file)
    print_duration(duration)

    # subtract 10min ending credits
    duration = duration - 10 * 60

    fps = count / duration

    args = [
      "-i",
      file,
      "-frames:v",
      "#{count}",
      "-vsync",
      "vfr",
      "-vf",
      "fps=#{fps}",
      "#{dir}/%d.jpg"
    ]

    Utils.measure("creating frames", fn ->
      {_, 0} = System.cmd(@ffmpeg, args, cd: dir)
    end)

    Utils.log("Resizing images")

    Utils.measure("resizing frames", fn ->
      :ok =
        1..count
        |> Enum.map(&"#{&1}.jpg")
        |> resize_frames(dir)
    end)
  end

  def video_duration(file) do
    args = ~w(-v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1)

    {duration, 0} = System.cmd("ffprobe", args ++ [file])

    duration
    |> String.trim()
    |> Float.parse()
    |> elem(0)
    |> trunc
  end

  defp print_duration(duration) do
    min = div(duration, 60)
    sec = rem(duration, 60)

    Utils.msg("Duration: #{min}m #{sec}s\n")
  end

  defp resize_frames(frames, dir) do
    mogrify_args = ~w(-resize 50x50!)

    {cmd, args} =
      if gnu_parallel_exists?() do
        Utils.msg("Using GNU parellel to speedup resize\n")
        parallel_args = ["mogrify"] ++ mogrify_args ++ ["{}", ":::"] ++ frames
        {"parallel", parallel_args}
      else
        Utils.msg("Using GNU parellel not found")
        {"mogrify", mogrify_args ++ ["*.jpg"]}
      end

    {_, 0} = System.cmd(cmd, args, cd: dir)
    :ok
  end

  defp gnu_parallel_exists?(), do: !!System.find_executable("parallel")
end
