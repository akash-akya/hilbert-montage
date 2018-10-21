defmodule Hilbert.Ffmpeg do
  alias Hilbert.Utils
  @ffmpeg "ffmpeg"

  def create_frames(file, count, bar_count, dir) do
    duration = video_duration(file)
    print_duration(duration)

    # subtract 10min ending credits
    duration = duration - 10 * 60

    fps = count / duration

    common_args = [
      "-hide_banner",
      "-i",
      file
    ]

    square_output = [
      "-vf",
      "fps=#{fps}",
      # "-vf",
      # "select=eq(pict_type\,I)",
      "-frames:v",
      "#{count}",
      "-s",
      "50x50",
      "#{dir}/square_%d.bmp"
    ]

    bar_output = [
      "-vf",
      "fps=#{fps}",
      "-frames:v",
      "#{bar_count}",
      "-s",
      "2x400",
      "#{dir}/bar_%d.bmp"
    ]

    Utils.measure("creating frames", fn ->
      {_, 0} = System.cmd(@ffmpeg, common_args ++ square_output ++ bar_output, cd: dir)
    end)

    :ok
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
end
