using LogCorner.EduSync.Speech.Presentation.Models; // Your Speech model
using Microsoft.AspNetCore.Mvc;

namespace LogCorner.EduSync.Speech.Presentation.Controllers
{
    public class SpeechController : Controller
    {
        private readonly IHttpClientFactory _httpClientFactory;
        private const string ApiBaseUrl = "http://localhost:7000/api/speech";

        public SpeechController(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }

        // GET: SpeechController
        public async Task<IActionResult> Index()
        {
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
    }
}