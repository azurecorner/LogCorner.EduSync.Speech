using LogCorner.EduSync.Speech.Application.Commands;
using LogCorner.EduSync.Speech.Application.Interfaces;
using LogCorner.EduSync.Speech.Presentation.Dtos;
using LogCorner.EduSync.Speech.Presentation.Exceptions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace LogCorner.EduSync.Speech.Presentation.Controllers
{
    [Route("api/speech")]
    [ApiController]
    public class SpeechController : ControllerBase
    {
        private readonly ICreateSpeechUseCase _createSpeechUseCase;
        private readonly IUpdateSpeechUseCase _updateSpeechUseCase;
        private readonly IDeleteSpeechUseCase _deleteSpeechUseCase;
        private readonly HealthCheckService _healthCheckService;

        public SpeechController(ICreateSpeechUseCase createSpeechUseCase, IUpdateSpeechUseCase updateSpeechUseCase, IDeleteSpeechUseCase deleteSpeechUseCase, HealthCheckService healthCheckService)
        {
            _createSpeechUseCase = createSpeechUseCase;
            _updateSpeechUseCase = updateSpeechUseCase;
            _deleteSpeechUseCase = deleteSpeechUseCase;
            _healthCheckService = healthCheckService;
        }

        [HttpPost]
        public async Task<IActionResult> Post([FromBody] SpeechForCreationDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var command = new RegisterSpeechCommandMessage(dto.Title, dto.Description, dto.Url, dto.Type);

            await _createSpeechUseCase.Handle(command);

            return Ok();
        }

        [HttpPut]
        public async Task<IActionResult> Put([FromBody] SpeechForUpdateDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var command = new UpdateSpeechCommandMessage(
                dto.Id == Guid.Empty ? throw new PresentationException("The speechId cannot be empty") : dto.Id,
                dto.Title, dto.Description,
                dto.Url,
                dto.TypeId,
                dto.Version);

            await _updateSpeechUseCase.Handle(command);
            return Ok();
        }

        [HttpDelete]
        public async Task<IActionResult> Delete([FromBody] SpeechForDeleteDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var command = new DeleteSpeechCommandMessage(dto.Id, dto.Version);

            await _deleteSpeechUseCase.Handle(command);
            return Ok();
        }

        [HttpGet]
        public async Task<IActionResult> GetReadiness()
        {
            var report = await _healthCheckService.CheckHealthAsync();

            if (report.Status == HealthStatus.Healthy)
            {
                return Ok(new { Status = "Ready", Message = "Application is ready to serve requests." });
            }
            else
            {
                return StatusCode(StatusCodes.Status503ServiceUnavailable, new
                {
                    Status = "Unready",
                    Message = "Application is not ready.",
                    checks = report.Entries.Select(entry => new
                    {
                        name = entry.Key,
                        Status = entry.Value.Status.ToString(),
                        description = entry.Value.Description ?? string.Empty
                    })
                });
            }
        }

        [HttpGet("health/{code}")]
        public async Task<HealthData> GetReadiness(string code)
        {
            if (code == "live")
            {
                return new HealthData { Status = "Healthy", Message = "Application is running." };
            }
            if (code == "ready")
            {
                var report = await _healthCheckService.CheckHealthAsync();

                if (report.Status == HealthStatus.Healthy)
                {
                    return new HealthData  { Status = "Ready", Message = "Application is ready to serve requests." };
                }
                else
                {
                    return  new HealthData
                    {
                        Status = "Unready",
                        Message = "Application is not ready.",
                        Checks = report.Entries.Select(entry => new HealthCheck
                        {
                            Name = entry.Key,
                            Status = entry.Value.Status.ToString(),
                            Description = entry.Value.Description ?? string.Empty
                        })
                    };
                }
            }
            return new HealthData  { Status = "Invalid", Message = "Invalid health check code." };
        }
    }

    public class HealthData
    {
        public string Status { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public IEnumerable<HealthCheck> Checks { get; set; } = Enumerable.Empty<HealthCheck>();
    }

    public class HealthCheck
    {
        public string Name { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
    }
}