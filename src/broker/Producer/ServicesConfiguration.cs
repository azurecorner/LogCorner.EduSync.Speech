using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace LogCorner.EduSync.Speech.Producer
{
    public static class ServicesConfiguration
    {
        public static void AddProducer(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddSingleton<IProducerService, ProducerService>();
           
        }
    }
}