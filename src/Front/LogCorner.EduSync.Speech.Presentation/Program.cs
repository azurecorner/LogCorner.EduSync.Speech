using LogCorner.EduSync.Notification.Common;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();
builder.Services.AddHttpClient(); // register IHttpClientFactory

// Add ChatBot HttpClient with configuration
builder.Services.AddHttpClient("ChatBotClient", client =>
{
    var chatBotUrl = builder.Configuration["ChatBotUrl"] ?? "https://localhost:7070";
    client.BaseAddress = new Uri(chatBotUrl);
    client.Timeout = TimeSpan.FromSeconds(30);
});

var publicHubEndpoint = builder.Configuration["HubUrl"];
var internalHubEndpoint = builder.Configuration["HubUrlInternal"];
var notificationHubEndpoint = string.IsNullOrWhiteSpace(internalHubEndpoint)
    ? publicHubEndpoint!
    : internalHubEndpoint;
builder.Services.AddSignalRServices($"{notificationHubEndpoint}?clientName=LogCorner.EduSync.Speech.Consumer");

var pathBase = builder.Configuration["pathBase"];

var app = builder.Build();

if (!string.IsNullOrWhiteSpace(pathBase))
{
    app.UsePathBase(new PathString(pathBase));
}

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthorization();
app.MapStaticAssets();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();

app.Run();