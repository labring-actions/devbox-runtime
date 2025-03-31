package main

import "github.com/kataras/iris/v12"

type PingResponse struct {
    Message string `json:"message"`
}

func main() {
    app := iris.New()
    app.Use(myMiddleware)

    app.Get("/", func(ctx iris.Context) {
        ctx.HTML(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>Hello World Page</title>
            </head>
            <body>
                <h1>Hello World</h1>
                <p>Welcome to my Iris web application!</p>
            </body>
            </html>
        `)
    })

    app.Get("/ping", func(ctx iris.Context) {
        res := PingResponse{
            Message: "pong",
        }
        ctx.JSON(res)
    })

    /* Same as:
    app.Handle("GET", "/ping", func(ctx iris.Context) {
        ctx.JSON(iris.Map{
            "message": "pong",
        })
    })
    */

    // Listens and serves incoming http requests
    // on http://localhost:8080.
    app.Listen(":8080")
}

func myMiddleware(ctx iris.Context) {
    ctx.Application().Logger().Infof("Runs before %s", ctx.Path())
    ctx.Next()
}