using LogCorner.EduSync.Speech.Consumer;
using LogCorner.EduSync.Speech.ServiceBus;
using Microsoft.Extensions.Configuration;

namespace LogCorner.EduSync.Speech.WorkerService
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = Host.CreateApplicationBuilder(args);
            builder.Services.AddHostedService<Worker>();
            builder.Services.AddConsumer();
            builder.Services.AddServiceBus();
            var host = builder.Build();
            host.Run();
        }
    }
}