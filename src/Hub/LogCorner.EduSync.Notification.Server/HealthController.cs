using Microsoft.AspNetCore.Mvc;

namespace LogCorner.EduSync.Notification.Server
{
    [Route("/")]
    [ApiController]
    public class HealthController : ControllerBase
    {
        [HttpGet("")]
        public IActionResult Status()
        {
            return Ok();
        }
    }
}