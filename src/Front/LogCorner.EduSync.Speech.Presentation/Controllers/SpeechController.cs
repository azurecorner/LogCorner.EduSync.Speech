using LogCorner.EduSync.Notification.Common.Hub;
using LogCorner.EduSync.Speech.Presentation.Models; // Your Speech model
using Microsoft.AspNetCore.Mvc;

namespace LogCorner.EduSync.Speech.Presentation.Controllers
{
    public class SpeechController : Controller
    {
        private readonly IHttpClientFactory _httpClientFactory;
        private const string ApiBaseUrl = "http://localhost:7000/api/speech";

        private readonly ISignalRNotifier? _notifier; // Make nullable to avoid CS8602
        private readonly ISignalRPublisher? _publisher;

        public SpeechController(IHttpClientFactory httpClientFactory, ISignalRNotifier notifier, ISignalRPublisher publisher)
        {
            _httpClientFactory = httpClientFactory;
            _notifier = notifier;
            _publisher = publisher;

            // Fix CS4033: Remove 'await' from constructor, use synchronous StartAsync call
            if (_notifier != null)
            {
                _notifier.StartAsync().GetAwaiter().GetResult(); // Synchronously wait for StartAsync
            }
        }

        // GET: SpeechController
        public async Task<IActionResult> Index()
        {
            await DoWorkAsync(); // ensure subscription/publish happens
            var client = _httpClientFactory.CreateClient();
            var speeches = await client.GetFromJsonAsync<List<SpeechModel>>(ApiBaseUrl);
            return View(speeches); // Pass list to the view
        }

        // GET: SpeechController/Details/5
        public async Task<IActionResult> Details(string id)
        {
            if (string.IsNullOrEmpty(id))
                return BadRequest();

            var client = _httpClientFactory.CreateClient();
            var speech = await client.GetFromJsonAsync<SpeechModel>($"{ApiBaseUrl}/{id}");

            if (speech == null)
                return NotFound();

            return View(speech); // Pass single speech to view
        }

        public async Task DoWorkAsync()
        {
            if (_publisher != null)
            {
                await _publisher.SubscribeAsync("Speech");
            }

            if (_notifier != null)
            {
                await _notifier.OnPublish("Speech");

                _notifier.ReceivedOnPublishToTopic += async (topic, header, @event) =>
                {
                    // Refresh the list when a new event is received
                    RedirectToAction("Index");
                };
            }
        }
    }
}