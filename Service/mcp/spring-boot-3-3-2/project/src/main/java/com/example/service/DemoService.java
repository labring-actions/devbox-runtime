package com.example.service;

import org.springframework.ai.tool.annotation.Tool;
import org.springframework.stereotype.Service;

@Service
public class DemoService {
    /**
     * Demo tool call.
     */
    @Tool(description = "demo tool call")
    public String toolCall() {
        return "Hello,World!";
    }

    public static void main(String[] args) {
        DemoService client = new DemoService();
    }

}