using LogCorner.EduSync.Speech.Command.SharedKernel;
using Microsoft.Extensions.DependencyInjection;

namespace LogCorner.EduSync.Speech.ServiceBus
{
    public static class ServicesConfiguration
    {
        public static void AddServiceBus(this IServiceCollection services)
        {
            services.AddSharedKernel();

            services.AddSingleton<IServiceBusProducer, AzureServiceBus>();
            services.AddSingleton<IServiceBusReceiver, AzureServiceBus>();
        }
    }
}