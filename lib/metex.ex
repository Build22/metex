defmodule Metex do

  def temperature_of(cities) do
    # 1. Create a Coordinator process
    coordinator_pid = spawn(Metex.Coordinator, :loop, [[], Enum.count(cities)])

    # 2. Iterate through each city
    cities |> Enum.each(
    fn city ->
      # 3. Create a worker process and execute its loop function
      worker_pid = spawn(Metex.Worker, :loop, [])
      # 4. Send the worker a message containing the coordinator pid and city
      send worker_pid, {coordinator_pid, city}
    end)
  end

end
