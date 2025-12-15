package main

import "github.com/kataras/iris/v12"

type PingResponse struct {
    Message string `json:"message"`
}

func main() {
    app := iris.New()
    app.Use(myMiddleware)

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