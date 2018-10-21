defmodule Hilbert.Montage do
  @montage "montage"
  @default_opt ["-geometry", "+0+0"]

  def create(files, output_file, dir) do
    {_, 0} = System.cmd(@montage, files ++ @default_opt ++ [output_file], cd: dir)
    :ok
  end

  def create_bar_montage(files, output_file, dir) do
    {_, 0} =
      System.cmd(
        @montage,
        files ++ ["-tile", "#{Enum.count(files)}x1"] ++ @default_opt ++ [output_file],
        cd: dir
      )

    :ok
  end
end
