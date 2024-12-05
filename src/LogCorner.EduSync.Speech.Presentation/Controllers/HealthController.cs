using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using System.Text.Json;

[Route("api/health")]
public class HealthStatusController : ControllerBase
{
    private readonly HealthCheckService _healthCheckService;

    public HealthStatusController(HealthCheckService healthCheckService)
    {
        _healthCheckService = healthCheckService;
    }

    // General Health Check Endpoint
    [HttpGet()]
    public async Task<IActionResult> GetHealth()
    {
        var report = await _healthCheckService.CheckHealthAsync();

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

        var json = JsonSerializer.Serialize(result);

        return report.Status == HealthStatus.Healthy
            ? Ok(json)
            : StatusCode(StatusCodes.Status503ServiceUnavailable, json);
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
