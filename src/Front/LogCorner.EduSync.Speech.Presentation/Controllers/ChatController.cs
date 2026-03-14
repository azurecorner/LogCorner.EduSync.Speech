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

       

        // POST: /Chat/SendMessage (for AJAX calls)
        [HttpPost]
        public async Task<IActionResult> SendMessage([FromBody] ChatMessageRequest request)
        {
            var stopwatch = Stopwatch.StartNew();
            
            if (string.IsNullOrWhiteSpace(request.Message))
            {
                stopwatch.Stop();
                _logger.LogWarning("⚠️ Empty message received after {Duration}ms", stopwatch.ElapsedMilliseconds);
                return Json(new { success = false, error = "Message cannot be empty" });
            }

            _logger.LogInformation("📤 Sending message to chatbot: {Message}", request.Message);

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
                        processingTime = stopwatch.ElapsedMilliseconds
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
       
    }
}
