using LogCorner.EduSync.Notification.Common;
using LogCorner.EduSync.Speech.Consumer;
using LogCorner.EduSync.Speech.CosmosDb;
using LogCorner.EduSync.Speech.ServiceBus;
using Microsoft.Azure.Cosmos;
using System.Configuration;

namespace LogCorner.EduSync.Speech.WorkerService
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = Host.CreateApplicationBuilder(args);

            var dotnetcoreenv = Environment.GetEnvironmentVariable("DOTNET_ENVIRONMENT") ?? throw new ArgumentNullException(nameof(Configuration), "DOTNET_ENVIRONMENT is missing.");
            builder.Configuration.AddJsonFile($"appsettings.{dotnetcoreenv}.json", optional: false, reloadOnChange: true);

            builder.Services.AddHostedService<Worker>();
            builder.Services.AddConsumer();
            builder.Services.AddServiceBus();

            var notificationHubEndpoint = builder.Configuration["HubUrl"];
            builder.Services.AddSignalRServices($"{notificationHubEndpoint}?clientName=LogCorner.EduSync.Speech.Consumer");

            builder.Services.RegisterCosmosDependencies(builder.Configuration);

            builder.Services.AddTransient<IDataService, DataService>();
            var host = builder.Build();
            host.Run();
        }
    }
}