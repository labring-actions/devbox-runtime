import { z } from 'zod'
import express, { Request, Response } from 'express'
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js'
import { SSEServerTransport } from '@modelcontextprotocol/sdk/server/sse.js'

interface ToolResult {
  [key: string]: unknown
  content: Array<{
    type: 'text'
    text: string
  }>
  isError?: boolean
}

interface PromptResult {
  [key: string]: unknown
  messages: Array<{
    role: 'user' | 'assistant'
    content: {
      type: 'text'
      text: string
    }
  }>
}

const server = new McpServer({
  name: 'mcp-sse-server',
  version: '1.0.0',
})

const textResource = {
  name: 'text-example',
  uri: 'resource://text-example',
  async callback() {
    return {
      contents: [
        {
          uri: 'resource://text-example',
          text: 'Hello, MCP!',
        },
      ],
    }
  },
}

server.resource(textResource.name, textResource.uri, textResource.callback)

const calculateTool = {
  name: 'calculate',
  description: 'Calculate the result of the expression',
  parameters: {
    expression: z.string().describe('The mathematical expression to calculate'),
  },
  async handler(extra: any): Promise<ToolResult> {
    try {
      const result = Function(`'use strict'; return (${extra.expression})`)()
      return {
        content: [
          {
            type: 'text',
            text: String(result),
          },
        ],
      }
    } catch (error: any) {
      return {
        content: [
          {
            type: 'text',
            text: `Calculation error: ${error.message}`,
          },
        ],
        isError: true,
      }
    }
  },
}

server.tool(
  calculateTool.name,
  calculateTool.description,
  calculateTool.parameters,
  calculateTool.handler
)

const codeAnalysisPrompt = {
  name: 'analyze-code',
  description: 'Analyze code and provide improvement suggestions',
  arguments: {
    language: z.string().describe('Programming language'),
    code: z.string().describe('Code to analyze'),
  },
  async getMessages(extra: any): Promise<PromptResult> {
    return {
      messages: [
        {
          role: 'user',
          content: {
            type: 'text',
            text: `Please analyze the following ${
              extra.language || 'unspecified'
            } code and provide improvement suggestions:\n\n\`\`\`${
              extra.language
            }\n${extra.code}\n\`\`\``,
          },
        },
      ],
    }
  },
}

server.prompt(
  codeAnalysisPrompt.name,
  codeAnalysisPrompt.description,
  codeAnalysisPrompt.arguments,
  codeAnalysisPrompt.getMessages
)

const app = express()

const transports: { [sessionId: string]: SSEServerTransport } = {}

app.get('/sse', async (_: Request, res: Response) => {
  const transport = new SSEServerTransport('/messages', res)
  transports[transport.sessionId] = transport

  res.on('close', () => {
    delete transports[transport.sessionId]
  })

  await server.connect(transport)
})

app.post('/messages', async (req: Request, res: Response) => {
  const sessionId = req.query.sessionId as string
  const transport = transports[sessionId]

  if (transport) {
    await transport.handlePostMessage(req, res)
  } else {
    res.status(400).send('not found')
  }
})

const PORT = process.env.PORT || 3001
app.listen(PORT, () => {
  console.log(`MCP SSE Running at http://localhost:${PORT}`)
})
