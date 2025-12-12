var builder = WebApplication.CreateBuilder(args);

// Configure to listen on 0.0.0.0:8080
builder.WebHost.UseUrls("http://0.0.0.0:8080");

var app = builder.Build();

// Add root route to display "Hello, World"
app.MapGet("/", () => "Hello, World");

app.Run();
