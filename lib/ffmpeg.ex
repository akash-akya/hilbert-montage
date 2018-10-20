defmodule Hilbert.Ffmpeg do
  @ffmpeg "ffmpeg"

  def create_frames(file, count, dir) do
    file = to_string(file)
    period = Float.floor(duration(file) / count) |> trunc()

    args = [
      "-i",
      file,
      "-frames:v",
      "#{count}",
      "-vsync",
      "vfr",
      "-vf",
      "fps=1/#{period}",
      "#{dir}/%04d.jpg"
    ]

    IO.inspect(Enum.join(args, " "))

    {_, 0} = System.cmd(@ffmpeg, args, cd: dir)

    :ok = resize_frames(dir)
  end

  def duration(file) do
    {duration, 0} =
      System.cmd("ffprobe", [
        "-v",
        "error",
        "-show_entries",
        "format=duration",
        "-of",
        "default=noprint_wrappers=1:nokey=1",
        file
      ])

    duration
    |> String.trim()
    |> Float.parse()
    |> elem(0)
  end

  defp resize_frames(dir) do
    {_, 0} = System.cmd("mogrify", ["-path", dir, "-resize", "50x50!", "*.jpg"], cd: dir)
    :ok
  end
end
