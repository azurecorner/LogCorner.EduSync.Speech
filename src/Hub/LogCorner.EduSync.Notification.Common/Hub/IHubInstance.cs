using Microsoft.AspNetCore.SignalR.Client;
using System.Threading.Tasks;

namespace LogCorner.EduSync.Notification.Common.Hub
{
    public interface IHubInstance
    {
        HubConnection Connection { get; }

        Task StartAsync();

        Task StopAsync();
    }
}