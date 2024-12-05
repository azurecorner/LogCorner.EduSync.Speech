namespace LogCorner.EduSync.Speech.Presentation.Controllers
{
    using Microsoft.AspNetCore.Diagnostics.HealthChecks;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Diagnostics.HealthChecks;
    using System.Text.Json;

    [Route("api/[controller]")]
    [ApiController]
    public class HealthSatusController : ControllerBase
    {
        private readonly HealthCheckService _healthCheckService;

        public HealthSatusController(HealthCheckService healthCheckService)
        {
            _healthCheckService = healthCheckService;
        }

        [HttpGet(Name = "GetHealthSatus")]
        public async Task<IActionResult> GetHealth()
        {
            // Run all registered health checks
            var report = await _healthCheckService.CheckHealthAsync();

            // Create a response based on the health report
            var result = new
            {
                status = report.Status.ToString(),
                checks = report.Entries.Select(entry => new
                {
                    name = entry.Key,
                    status = entry.Value.Status.ToString(),
                    description = entry.Value.Description ?? string.Empty
                })
            };

            // Serialize the response
            var json = JsonSerializer.Serialize(result);

            // Return appropriate HTTP status code
            return report.Status == HealthStatus.Healthy
                ? Ok(json)
                : StatusCode(StatusCodes.Status503ServiceUnavailable, json);
        }
    }

}
