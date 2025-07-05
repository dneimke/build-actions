using Shared;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Register EchoService
builder.Services.AddSingleton<EchoService>();

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Define minimal API endpoints
app.MapGet("/echo/{message}", (string message, EchoService echoService) =>
{
    return echoService.Echo(message);
})
.WithName("GetEcho")
.WithOpenApi();

// POST endpoint that accepts a message in the request body
app.MapPost("/echo", ([FromBody] EchoRequest request, EchoService echoService, HttpContext context) =>
{
    if (request == null || string.IsNullOrEmpty(request.Message))
    {
        return Results.BadRequest("Message is required");
    }
    
    return Results.Ok(echoService.ProcessEchoRequest(request, context.Request.Method));
})
.WithName("PostEcho")
.WithOpenApi();

// PUT endpoint with query parameters
app.MapPut("/echo/{message}", (string message, [FromQuery] int count, EchoService echoService, HttpContext context) =>
{
    if (count <= 0 || count > 10)
    {
        return Results.BadRequest("Count must be between 1 and 10");
    }
    
    return Results.Ok(echoService.EchoWithDetails(message, count));
})
.WithName("PutEchoWithCount")
.WithOpenApi();

// DELETE endpoint returning status code
app.MapDelete("/echo/{message}", (string message, EchoService echoService, HttpContext context) =>
{
    return Results.Ok(echoService.EchoWithMethod(message, context.Request.Method));
})
.WithName("DeleteEcho")
.WithOpenApi();

// Add a root endpoint that redirects to swagger
app.MapGet("/", () => Results.Redirect("/swagger")).ExcludeFromDescription();

app.Run();

