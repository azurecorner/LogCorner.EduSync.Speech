using Microsoft.AspNetCore.Mvc;
using System.Text;
using System.Text.Json;
using System.Diagnostics;

namespace LogCorner.EduSync.Speech.Presentation.Controllers
{
    public class ChatController : Controller
    {
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly ILogger<ChatController> _logger;

        public ChatController(IHttpClientFactory httpClientFactory, ILogger<ChatController> logger)
        {
            _httpClientFactory = httpClientFactory;
            _logger = logger;
        }

        // GET: /Chat
        public IActionResult SendMessage()
        {
            return View(new ChatMessageRequest());
        }

        // POST: /Chat/SendMessage
        //[HttpPost]
        //[ValidateAntiForgeryToken]
        //public async Task<IActionResult> SendMessage(   ChatMessageRequest request)
        //{
        //    if (string.IsNullOrWhiteSpace(request.Message))
        //    {
        //        return BadRequest(new { success = false, error = "Message cannot be empty" });
        //    }

        //    var stopwatch = Stopwatch.StartNew();
        //    _logger.LogInformation("📤 Sending message to chatbot: {Message}", request.Message);

        //    try
        //    {
        //        var httpClient = _httpClientFactory.CreateClient("ChatBotClient");

        //        var chatRequest = new
        //        {
        //            userId = User.Identity?.Name ?? request.UserId ?? "anonymous",
        //            message = request.Message
        //        };

        //        var jsonContent = JsonSerializer.Serialize(chatRequest);
        //        var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");

        //        var response = await httpClient.PostAsync("/Chat", content);
                
        //        stopwatch.Stop();

        //        if (response.IsSuccessStatusCode)
        //        {
        //            var responseContent = await response.Content.ReadAsStringAsync();
        //            var chatResponse = JsonSerializer.Deserialize<ChatBotResponse>(
        //                responseContent,
        //                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

        //            _logger.LogInformation(
        //                "✅ Received chatbot response in {Duration}ms", 
        //                stopwatch.ElapsedMilliseconds);

        //            return Json(new
        //            {
        //                success = true,
        //                reply = chatResponse?.Reply ?? "No response",
        //                processingTime = chatResponse?.ProcessingTimeMs ?? stopwatch.ElapsedMilliseconds,
        //                timestamp = DateTime.Now
        //            });
        //        }
        //        else
        //        {
        //            var errorContent = await response.Content.ReadAsStringAsync();
        //            _logger.LogError(
        //                "❌ ChatBot API error: {Status} - {Content}", 
        //                response.StatusCode, 
        //                errorContent);

        //            return StatusCode((int)response.StatusCode, new
        //            {
        //                success = false,
        //                error = $"ChatBot service returned {response.StatusCode}",
        //                details = errorContent
        //            });
        //        }
        //    }
        //    catch (HttpRequestException ex)
        //    {
        //        stopwatch.Stop();
        //        _logger.LogError(ex, "❌ Network error calling chatbot service after {Duration}ms", stopwatch.ElapsedMilliseconds);
        //        return StatusCode(503, new
        //        {
        //            success = false,
        //            error = "ChatBot service is unavailable. Please ensure the service is running on https://localhost:7070",
        //            details = ex.Message
        //        });
        //    }
        //    catch (TaskCanceledException ex)
        //    {
        //        stopwatch.Stop();
        //        _logger.LogError(ex, "⏰ Timeout calling chatbot service after {Duration}ms", stopwatch.ElapsedMilliseconds);
        //        return StatusCode(504, new
        //        {
        //            success = false,
        //            error = "ChatBot service request timed out",
        //            details = ex.Message
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        stopwatch.Stop();
        //        _logger.LogError(ex, "❌ Unexpected error calling chatbot service after {Duration}ms", stopwatch.ElapsedMilliseconds);
        //        return StatusCode(500, new
        //        {
        //            success = false,
        //            error = "An unexpected error occurred",
        //            details = ex.Message
        //        });
        //    }
        //}

        // POST: /Chat/SendMessage (for AJAX calls)
        [HttpPost]
        public async Task<IActionResult> SendMessage([FromBody] ChatMessageRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Message))
            {
                return Json(new { success = false, error = "Message cannot be empty" });
            }

            try
            {
                var httpClient = _httpClientFactory.CreateClient("ChatBotClient");

                var chatRequest = new
                {
                    userId = request.UserId ?? "anonymous",
                    message = request.Message
                };

                var jsonContent = JsonSerializer.Serialize(chatRequest);
                var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");

                var response = await httpClient.PostAsync("/Chat", content);

                if (response.IsSuccessStatusCode)
                {
                    var responseContent = await response.Content.ReadAsStringAsync();
                    var chatResponse = JsonSerializer.Deserialize<ChatBotResponse>(
                        responseContent,
                        new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

                    return Json(new
                    {
                        success = true,
                        reply = chatResponse?.Reply ?? "No response",
                        processingTime = chatResponse?.ProcessingTimeMs ?? 0
                    });
                }
                else
                {
                    return Json(new { success = false, error = "ChatBot service error" });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calling chatbot");
                return Json(new { success = false, error = ex.Message });
            }
        }

        // POST: /Chat/HealthCheck - Check if chatbot service is available
        [HttpPost]
        public async Task<IActionResult> HealthCheck()
        {
            try
            {
                var httpClient = _httpClientFactory.CreateClient("ChatBotClient");
                var response = await httpClient.GetAsync("/Chat/health");
                
                return Json(new
                {
                    success = response.IsSuccessStatusCode,
                    status = response.StatusCode,
                    message = response.IsSuccessStatusCode ? "ChatBot service is healthy" : "ChatBot service is unavailable"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Health check failed");
                return Json(new
                {
                    success = false,
                    message = "Cannot connect to ChatBot service",
                    error = ex.Message
                });
            }
        }
    }

    public class ChatMessageRequest
    {
        public string? UserId { get; set; }
        public string Message { get; set; } = string.Empty;
    }

    public class ChatBotResponse
    {
        public string UserId { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string Reply { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; }
        public int ProcessingTimeMs { get; set; }
    }
}
