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
                new SpeechType { Value = 1, Name = "SelfPacedLabs" },
                new SpeechType { Value = 2, Name = "TraingVideo" },
                new SpeechType { Value = 3, Name = "Conferences" }
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
                     new SpeechType { Value = 1, Name = "SelfPacedLabs" },
                new SpeechType { Value = 2, Name = "TraingVideo" },
                new SpeechType { Value = 3, Name = "Conferences" }
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
                    new SpeechType { Value = 1, Name = "SelfPacedLabs" },
                new SpeechType { Value = 2, Name = "TraingVideo" },
                new SpeechType { Value = 3, Name = "Conferences" }
                };

                return View(model);
            }
            catch
            {
                // Repopulate dropdown for redisplay
                ViewBag.SpeechTypes = new List<SpeechType>
                {
                    new SpeechType { Value = 1, Name = "SelfPacedLabs" },
                new SpeechType { Value = 2, Name = "TraingVideo" },
                new SpeechType { Value = 3, Name = "Conferences" }
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
                new SelectListItem { Value = "1", Text = "SelfPacedLabs" },
                new SelectListItem { Value = "2", Text = "TraingVideo" },
                new SelectListItem { Value = "3", Text = "Conferences" }
            };

            return View(new SpeechModelForUpdate
            {
                Id = new Guid(speech.Id),
                Title = speech.Title,
                Description = speech.Description,
                Url = speech.Url,
                TypeId = speech.Type.Value,
                Version = speech.Version
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
                 new SelectListItem { Value = "1", Text = "SelfPacedLabs" },
                new SelectListItem { Value = "2", Text = "TraingVideo" },
                new SelectListItem { Value = "3", Text = "Conferences" }
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
               new SelectListItem { Value = "1", Text = "SelfPacedLabs" },
                new SelectListItem { Value = "2", Text = "TraingVideo" },
                new SelectListItem { Value = "3", Text = "Conferences" }
            };

            return View(model);
        }

        // GET: Speech/Delete/{id}
        public async Task<IActionResult> Delete(Guid id)
        {
            var client = _httpClientFactory.CreateClient();

            // Here, you probably need to call your query API to fetch the speech version
            var speech = _speeches.SingleOrDefault(s => s.Id == id.ToString());
            if (speech == null)
            {
                _logger.LogInformation("Speech not found with id: {Id}", id);
                return NotFound();
            }

            var model = new SpeechModelForDelete
            {
                Id = Guid.Parse(speech.Id),
                Version = speech.Version
            };

            return View(model); // pass delete model to confirmation view
        }

        // POST: Speech/Delete/{id}
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(SpeechModelForDelete model)
        {
            try
            {
                var client = _httpClientFactory.CreateClient();

                var request = new HttpRequestMessage(HttpMethod.Delete, $"{commandApiBaseUrl}")
                {
                    Content = JsonContent.Create(model) // includes Id + Version in body
                };

                var response = await client.SendAsync(request);

                if (response.IsSuccessStatusCode)
                {
                    _logger.LogInformation("Deleted speech with id: {Id}", model.Id);
                    return RedirectToAction(nameof(Index));
                }

                _logger.LogError("Failed to delete speech with id: {Id}. Status Code: {StatusCode}",
                                 model.Id, response.StatusCode);

                ModelState.AddModelError("", "Unable to delete speech.");
                return View(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Exception when deleting speech with id: {Id}", model.Id);
                return View(model);
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