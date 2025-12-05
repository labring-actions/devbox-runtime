#!/bin/bash

# Variable to hold the PID of the netcat listener
NC_PID=0

# Function to run when SIGTERM or SIGINT is received
cleanup() {
    echo "Caught SIGTERM/SIGINT. Attempting to shut down netcat (PID: $NC_PID)..."
    
    # Check if NC_PID is set and the process is still running
    if [[ $NC_PID -ne 0 ]] && kill -0 "$NC_PID" 2>/dev/null; then
        echo "Sending SIGTERM to netcat..."
        # Send SIGTERM to the background netcat process
        kill -SIGTERM "$NC_PID"
        # Wait briefly for netcat to clean up
        wait "$NC_PID" 2>/dev/null
    fi

    echo "Server shutdown complete."
    exit 0
}

# Trap the signals and run the cleanup function
trap cleanup SIGTERM SIGINT

echo "Simple web server started on port 8080. PID: $$"
echo "Press Ctrl+C or send SIGTERM to PID $$ to stop."

while :; do
    # Run netcat in the background (&) and capture its PID ($!)
    { echo -ne "HTTP/1.1 200 OK\r\nContent-Length: $(echo -n "Hello, World!" | wc -c)\r\n\r\nHello, World!"; } | nc -l -p 8080 -q 1 &
    NC_PID=$!
    
    # Wait for the netcat process to finish (either by connection or signal)
    wait "$NC_PID"

    # Reset PID for the next loop iteration
    NC_PID=0
done

exit 0