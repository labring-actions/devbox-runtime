#include <iostream>
#include <string>
#include <cstring>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

int main() {
    // Create socket
    int server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd < 0) {
        std::cerr << "Failed to create socket" << std::endl;
        return 1;
    }

    // Set socket options
    int opt = 1;
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0) {
        std::cerr << "Failed to set socket options" << std::endl;
        return 1;
    }

    // Configure address
    struct sockaddr_in address;
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY; // 0.0.0.0
    address.sin_port = htons(8080);

    // Bind socket
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        std::cerr << "Failed to bind to port" << std::endl;
        return 1;
    }

    // Listen for connections
    if (listen(server_fd, 3) < 0) {
        std::cerr << "Listen failed" << std::endl;
        return 1;
    }

    std::cout << "Server listening on 0.0.0.0:8080" << std::endl;

    while (true) {
        // Accept connection
        int socket = accept(server_fd, NULL, NULL);
        if (socket < 0) {
            std::cerr << "Accept failed" << std::endl;
            continue;
        }

        // Prepare HTTP response
        std::string hello = "Hello, World!";
        std::string http_response =
            "HTTP/1.1 200 OK\r\n"
            "Content-Type: text/plain\r\n"
            "Content-Length: " + std::to_string(hello.length()) + "\r\n"
            "Connection: close\r\n"
            "\r\n" +
            hello;

        // Send response
        send(socket, http_response.c_str(), http_response.length(), 0);

        // Close connection
        close(socket);
    }

    return 0;
}
