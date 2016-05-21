defmodule Metex.Worker do

  def loop do
    receive do
      {sender_pid, location} ->
        send(sender_pid, {:ok, temperature_of(location)})
      _ ->
        IO.puts "dont know how to process this message"
    end
    #  If we left the recursive call out, the moment the process handles that first (and only) message, it will exit, and get garbage collected. We usually want our processes to be able to handle more than one process! Therefore, we need a recursive call to the message handling logic.
    loop
  end

  def temperature_of(location) do
    result = url_for(location) |> HTTPoison.get |> parse_response
    case result do
      {:ok, temp} ->
        "#{location}: #{temp}°C"
      :error ->
        "#{location} not found"
    end
  end

  defp url_for(location) do
    encoded_location = URI.encode location
    "http://api.openweathermap.org/data/2.5/weather?q=#{encoded_location}&APPID=0b4c956e618521a3b77228b61bd8b8fb"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode! |> compute_temperature
  end

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

end
