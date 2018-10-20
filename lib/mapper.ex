defmodule Hilbert.Mapper do
  alias Hilbert.Montage

  def map(res) do
    mapping =
      0..(res * res - 1)
      |> Enum.map(fn n -> {pos(n, res), n + 1} end)
      |> Enum.into(%{})

    Enum.flat_map(0..(res - 1), fn x ->
      Enum.map(0..(res - 1), &mapping[{x, &1}])
    end)
  end

  defp flip({y, x}, _res), do: {x, y}

  defp counter_flip({y, x}, res), do: {res - 1 - x, res - 1 - y}

  defp first(n, res) do
    flip(pos(n, res), res)
  end

  defp second(n, res) do
    {y, x} = pos(n, res)
    {y + res, x}
  end

  defp third(n, res) do
    {y, x} = pos(n, res)
    {y + res, x + res}
  end

  defp fourth(n, res) do
    {y, x} = counter_flip(pos(n, res), res)
    {y, x + res}
  end

  defp pos(n, 2) do
    case n do
      0 -> {0, 0}
      1 -> {1, 0}
      2 -> {1, 1}
      3 -> {0, 1}
      _ -> raise ArgumentError, "Number should be less than 4"
    end
  end

  defp pos(n, res) do
    x = div(res * res, 4)
    sub_pos = rem(n, x)
    sub_res = div(res, 2)

    case div(n, x) do
      0 -> first(sub_pos, sub_res)
      1 -> second(sub_pos, sub_res)
      2 -> third(sub_pos, sub_res)
      3 -> fourth(sub_pos, sub_res)
    end
  end
end
