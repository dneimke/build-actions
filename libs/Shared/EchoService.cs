namespace Shared;

public class EchoService
{
    public string Echo(string message)
    {
        return $"Echo: {message}";
    }

    public string EchoWithMethod(string message, string method)
    {
        return $"Echo [{method}]: {message}";
    }

    public string EchoWithDetails(string message, int count)
    {
        var result = string.Empty;
        for (int i = 0; i < count; i++)
        {
            result += $"Echo {i + 1}: {message}\n";
        }
        return result.TrimEnd();
    }

    public string ProcessEchoRequest(EchoRequest request, string method)
    {
        if (request.Message == null)
        {
            return "Echo request missing message";
        }

        string message = request.Uppercase
            ? request.Message.ToUpper()
            : request.Message;

        return $"Echo [{method}]: {message}";
    }

    public string GetTimestamp()
    {
        return $"The current timestamp is: {DateTime.Now:yyyy-MM-dd HH:mm:ss}";
    }
}