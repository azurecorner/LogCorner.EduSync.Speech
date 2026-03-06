using System.Collections.Generic;
using System.Threading.Tasks;

namespace LogCorner.EduSync.Notification.Common.Hub
{
    public interface IHubNotifier<in T>
    {
        Task OnPublish(T payload);

        Task OnPublish(string topic, IDictionary<string, string> headers, T payload);

        Task OnSubscribe(string connectionId, string topic);

        Task OnUnSubscribe(string connectionId, string topic);
    }
}