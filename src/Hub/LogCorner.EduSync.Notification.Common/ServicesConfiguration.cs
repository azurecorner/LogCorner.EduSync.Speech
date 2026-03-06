using LogCorner.EduSync.Notification.Common.Hub;
using Microsoft.Extensions.DependencyInjection;

namespace LogCorner.EduSync.Notification.Common
{
    public static class ServicesConfiguration
    {
        public static void AddSignalRServices(this IServiceCollection services, string endpoint)
        {
            services.AddSingleton<ISignalRNotifier, SignalRNotifier>();
            services.AddSingleton<ISignalRPublisher, SignalRPublisher>();

            services.AddHttpContextAccessor();
            services.AddSingleton<IHubInstance, HubConnectionInstance>(ctx => new HubConnectionInstance(endpoint

            ));
        }
    }
}