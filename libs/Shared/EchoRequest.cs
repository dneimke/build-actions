namespace Shared;

public class EchoRequest
{
    public string? Message { get; set; }
    public bool Uppercase { get; set; }
    
    public EchoRequest()
    {
        // Default constructor for deserialization
    }
    
    public EchoRequest(string message, bool uppercase = false)
    {
        Message = message;
        Uppercase = uppercase;
    }
} 