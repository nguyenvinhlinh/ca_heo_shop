defmodule CaHeoShop.FFmpegRunner do
  @moduledoc false

  def generate_square_thumbnail(input_path, output_path, size) do
    args = [
      "-y",
      "-i",
      input_path,
      "-vf",
      "scale=#{size}:#{size}:force_original_aspect_ratio=increase,crop=#{size}:#{size}",
      output_path
    ]

    case System.cmd("ffmpeg", args, stderr_to_stdout: true) do
      {_output, 0} -> :ok
      {output, _status} -> {:error, output}
    end
  rescue
    error -> {:error, Exception.message(error)}
  end
end
