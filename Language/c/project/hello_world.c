#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <signal.h>
#include <time.h>
#include <errno.h>

#define BUFFER_SIZE 1024

// Global variable for graceful shutdown
volatile sig_atomic_t keep_running = 1;

// Signal handler function
void handle_signal(int sig) {
    keep_running = 0;
}

// Get current time string
void get_time_string(char* buffer, size_t size) {
    time_t now = time(NULL);
    strftime(buffer, size, "%Y-%m-%d %H:%M:%S", localtime(&now));
}

// Get port from environment variable
int get_port() {
    char* env_port = getenv("PORT");
    if (env_port != NULL) {
        return atoi(env_port);
    }
    // Default port 8080 for development
    return 8080;
}

int main() {
    int server_fd, new_socket;
    struct sockaddr_in address;
    int addrlen = sizeof(address);
    char buffer[BUFFER_SIZE] = {0};
    char time_buffer[64];

    // Setup signal handlers
    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    int port = get_port();

    // Set response content based on environment
    char *http_response;

    http_response = "HTTP/1.1 200 OK\r\n"
                    "Content-Type: text/html\r\n"
                    "Content-Length: 37\r\n"
                    "\r\n"
                    "Hello, World from Development Server!";

    // Create socket
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    // Set socket options to reuse address and port
    int opt = 1;
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt))) {
        perror("setsockopt failed");
        exit(EXIT_FAILURE);
    }

    // Configure socket address
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY; // Equivalent to 0.0.0.0
    address.sin_port = htons(port);

    // Bind socket to port
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }

    // Start listening
    if (listen(server_fd, 10) < 0) {
        perror("Listen failed");
        exit(EXIT_FAILURE);
    }

    printf("Server started successfully, listening on 0.0.0.0:%d\n", port);

    // Main loop
    while (keep_running) {
        // Set accept timeout
        struct timeval tv;
        tv.tv_sec = 1;
        tv.tv_usec = 0;
        setsockopt(server_fd, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof tv);

        new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen);
        if (new_socket < 0) {
            if (errno == EAGAIN || errno == EWOULDBLOCK) {
                continue;  // Timeout, continue loop
            }
            perror("Accept failed");
            continue;
        }

        // Get client IP
        char client_ip[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &(address.sin_addr), client_ip, INET_ADDRSTRLEN);

        // Log access
        get_time_string(time_buffer, sizeof(time_buffer));
        printf("[%s] Request from %s\n", time_buffer, client_ip);

        read(new_socket, buffer, BUFFER_SIZE);
        write(new_socket, http_response, strlen(http_response));

        close(new_socket);
    }

    // Cleanup resources
    close(server_fd);
    printf("\nServer shutting down gracefully...\n");

    return 0;
}
