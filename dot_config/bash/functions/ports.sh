kill_port() {
  if [ -z "$1" ]; then
    echo "Usage: kill_port <port_number>"
    echo "Example: kill_port 3000"
    return 1
  fi

  local port=$1

  # Check if port is a valid number
  if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    echo "Error: Port must be a number"
    return 1
  fi

  # Find processes on the port
  local pids=$(lsof -t -i:$port 2>/dev/null)

  if [ -z "$pids" ]; then
    echo "No processes found running on port $port"
    return 0
  fi

  # Show what processes will be killed
  echo "Found processes on port $port:"
  lsof -i:$port

  # Kill the processes
  echo "Killing processes with PIDs: $pids"
  kill -9 $pids

  if [ $? -eq 0 ]; then
    echo "Successfully killed processes on port $port"
  else
    echo "Error killing some processes. You may need sudo privileges."
    return 1
  fi
}
