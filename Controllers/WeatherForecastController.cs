using Microsoft.AspNetCore.Mvc;

namespace MyApi.Controllers;

[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Sunny", "Cloudy", "Rainy", "Windy", "Stormy", "Snowy"
    };

    [HttpGet]
    public IEnumerable<string> Get()
    {
        return Summaries.OrderBy(_ => Guid.NewGuid()).Take(6);
    }
}
