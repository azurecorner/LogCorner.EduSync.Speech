using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace WebApplication2.Controllers
{
    [ApiController]
    [Route("api/WeatherForecast")]
    public class WeatherForecastController : ControllerBase
    {

        private readonly HealthCheckService _healthCheckService;

   

        private static readonly string[] Summaries = new[]
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };

        private readonly ILogger<WeatherForecastController> _logger;

        public WeatherForecastController(ILogger<WeatherForecastController> logger, HealthCheckService healthCheckService)
        {
            _logger = logger;
            _healthCheckService = healthCheckService;
        }

        [HttpGet("all")]
        public IEnumerable<WeatherForecast> Get()
        {
            return Enumerable.Range(1, 5).Select(index => new WeatherForecast
            {
                Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                TemperatureC = Random.Shared.Next(-20, 55),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)]
            })
            .ToArray();
        }

        [HttpGet("by-id/{id}")]
        public WeatherForecast? Get(int id)
        {
            return Enumerable.Range(1, 5).Select(index => new WeatherForecast
            {
                Id = index,
                Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                TemperatureC = Random.Shared.Next(-20, 55),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)]
            })?.SingleOrDefault(m => m.Id == id);
        }

        // Liveness Probe Endpoint
        [HttpGet("live")]
        public IActionResult GetLiveness()
        {
            return Ok(new { status = "Healthy", message = "Application is running." });
        }

        // Readiness Probe Endpoint
        [HttpGet("ready")]
        public async Task<IActionResult> GetReadiness()
        {
            var report = await _healthCheckService.CheckHealthAsync();

            if (report.Status == HealthStatus.Healthy)
            {
                return Ok(new { status = "Ready", message = "Application is ready to serve requests." });
            }
            else
            {
                return StatusCode(StatusCodes.Status503ServiceUnavailable, new
                {
                    status = "Unready",
                    message = "Application is not ready.",
                    checks = report.Entries.Select(entry => new
                    {
                        name = entry.Key,
                        status = entry.Value.Status.ToString(),
                        description = entry.Value.Description ?? string.Empty
                    })
                });
            }
        }
    }

    public class WeatherForecast
    {
        public int Id { get; set; }
        public DateOnly Date { get; set; }

        public int TemperatureC { get; set; }

        public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);

        public string? Summary { get; set; }
    }
}