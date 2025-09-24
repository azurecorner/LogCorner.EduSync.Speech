using LogCorner.EduSync.Notification.Common.Hub;
using LogCorner.EduSync.Speech.Presentation.Models; // Your Speech model
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace LogCorner.EduSync.Speech.Presentation.Controllers
{
    public class SpeechController : Controller
    {
        private readonly IHttpClientFactory _httpClientFactory;
        private const string queryApiBaseUrl = "http://localhost:7000/api/speech";
        private const string commandApiBaseUrl = "https://localhost:6001/api/speech";

        private readonly ISignalRNotifier? _notifier; // Make nullable to avoid CS8602
        private readonly ISignalRPublisher? _publisher;
        private readonly ILogger<SpeechController> _logger;

        private static List<SpeechModel> _speeches;

        public SpeechController(IHttpClientFactory httpClientFactory, ISignalRNotifier notifier, ISignalRPublisher publisher, ILogger<SpeechController> logger)
        {
            _httpClientFactory = httpClientFactory;
            _notifier = notifier;
            _publisher = publisher;

            // Fix CS4033: Remove 'await' from constructor, use synchronous StartAsync call
            if (_notifier != null)
            {
                _notifier.StartAsync().GetAwaiter().GetResult(); // Synchronously wait for StartAsync
            }

            _logger = logger;
            //  _speeches = new List<SpeechModel>();
        }

        // Returns the partial table only
        [HttpGet]
        public async Task<IActionResult> IndexPartial()
        {
            var client = _httpClientFactory.CreateClient();
            _speeches = await client.GetFromJsonAsync<List<SpeechModel>>(queryApiBaseUrl) ?? new List<SpeechModel>();
            return PartialView("_SpeechListPartial", _speeches); // partial from Shared folder
        }

        // GET: SpeechController
        public async Task<IActionResult> Index()
        {
            // await DoWorkAsync(); // ensure subscription/publish happens
            var client = _httpClientFactory.CreateClient();
            _speeches = await client.GetFromJsonAsync<List<SpeechModel>>(queryApiBaseUrl) ?? new List<SpeechModel>();
            return View(_speeches); // Pass list to the view
            //return PartialView("_SpeechListPartial", speeches);
        }

        // GET: SpeechController/Details/5
        public async Task<IActionResult> Details(string id)
        {
            if (string.IsNullOrEmpty(id))
                return BadRequest();

            var client = _httpClientFactory.CreateClient();
            var speech = await client.GetFromJsonAsync<SpeechModel>($"{queryApiBaseUrl}/{id}");

            if (speech == null)
                return NotFound();

            return View(speech); // Pass single speech to view
        }

        // GET: HomeController1/Create
        public ActionResult Create()
        {
            ViewBag.SpeechTypes = new List<SpeechType>
            {
                new SpeechType { Value = 1, Name = "Conference" },
                new SpeechType { Value = 2, Name = "Podcast" },
                new SpeechType { Value = 3, Name = "Interview" }
            };
            return View(new SpeechModelForCreation());
        }

        // POST: HomeController1/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> Create(SpeechModelForCreation model)
        {
            if (!ModelState.IsValid)
            {
                // Repopulate dropdown when validation fails
                ViewBag.SpeechTypes = new List<SpeechType>
                {
                    new SpeechType { Value = 1, Name = "Conference" },
                    new SpeechType { Value = 2, Name = "Podcast" },
                    new SpeechType { Value = 3, Name = "Interview" }
                };

                return View(model);
            }

            try
            {
                var client = _httpClientFactory.CreateClient();

                // send JSON payload
                var response = await client.PostAsJsonAsync(commandApiBaseUrl, model);

                if (response.IsSuccessStatusCode)
                {
                    return RedirectToAction(nameof(Index));
                }

                // fallback if API returned error
                ModelState.AddModelError("", "Unable to create speech.");

                // Repopulate dropdown for redisplay
                ViewBag.SpeechTypes = new List<SpeechType>
                {
                    new SpeechType { Value = 1, Name = "Conference" },
                    new SpeechType { Value = 2, Name = "Podcast" },
                    new SpeechType { Value = 3, Name = "Interview" }
                };

                return View(model);
            }
            catch
            {
                // Repopulate dropdown for redisplay
                ViewBag.SpeechTypes = new List<SpeechType>
                {
                    new SpeechType { Value = 1, Name = "Conference" },
                    new SpeechType { Value = 2, Name = "Podcast" },
                    new SpeechType { Value = 3, Name = "Interview" }
                };

                return View(model);
            }
        }

        // GET: Speech/Edit/{id}
        public async Task<IActionResult> Edit(Guid id)
        {
            var client = _httpClientFactory.CreateClient();

            // Fetch existing speech
            var speech = _speeches.SingleOrDefault(s => s.Id == id.ToString());
            if (speech == null)
            {
                _logger.LogInformation("Speech not found with id: {Id}", id);
                return NotFound();
            }

            // Populate dropdown
            ViewBag.SpeechTypes = new List<SelectListItem>
            {
                new SelectListItem { Value = "1", Text = "Conference" },
                new SelectListItem { Value = "2", Text = "Podcast" },
                new SelectListItem { Value = "3", Text = "Interview" }
            };

            return View(new SpeechModelForUpdate
            {
                Id = id,
                Title = speech.Title,
                Description = speech.Description,
                Url = speech.Url,
                TypeId = speech.Type.Value
            });
        }

        // POST: Speech/Edit/{id}
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(SpeechModelForUpdate model)
        {
            if (!ModelState.IsValid)
            {
                // repopulate dropdown when redisplaying form
                ViewBag.SpeechTypes = new List<SelectListItem>
            {
                new SelectListItem { Value = "1", Text = "Conference" },
                new SelectListItem { Value = "2", Text = "Podcast" },
                new SelectListItem { Value = "3", Text = "Interview" }
            };

                return View(model);
            }

            try
            {
                var client = _httpClientFactory.CreateClient();
                var response = await client.PutAsJsonAsync($"{commandApiBaseUrl}", model);

                if (response.IsSuccessStatusCode)
                {
                    return RedirectToAction(nameof(Index));
                }

                ModelState.AddModelError("", "Unable to update speech.");
            }
            catch
            {
                ModelState.AddModelError("", "Unexpected error while updating speech.");
            }

            // repopulate dropdown before returning view again
            ViewBag.SpeechTypes = new List<SelectListItem>
            {
                new SelectListItem { Value = "1", Text = "Conference" },
                new SelectListItem { Value = "2", Text = "Podcast" },
                new SelectListItem { Value = "3", Text = "Interview" }
            };

            return View(model);
        }

        // GET: HomeController1/Delete/5
        public ActionResult Delete(int id)
        {
            return View();
        }

        // POST: HomeController1/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id, IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        private async Task DoWorkAsync()
        {
            if (_publisher != null)
            {
                await _publisher.SubscribeAsync("ReadModelAcknowledged");
            }

            if (_notifier != null)
            {
                await _notifier.OnPublish("ReadModelAcknowledged");

                _notifier.ReceivedOnPublishToTopic += async (topic, header, @event) =>
                {
                    // Instead of RedirectToAction, broadcast update to clients
                    if (_publisher != null && topic == "ReadModelAcknowledged")
                    {
                        // Create headers (could reuse existing, or keep minimal)
                        var headers = new Dictionary<string, string>
                        {
                            { "source", "SpeechController" },
                            { "eventType", "SpeechUpdated" }
                        };

                        await _publisher.PublishAsync("SpeechUpdated", headers, @event);
                    }
                };
            }
        }
    }
}