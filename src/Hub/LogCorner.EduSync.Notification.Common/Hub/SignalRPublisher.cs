using LogCorner.EduSync.Notification.Common.Model;
using Microsoft.AspNetCore.SignalR.Client;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace LogCorner.EduSync.Notification.Common.Hub
{
    public class SignalRPublisher : ISignalRPublisher
    {
        private readonly IHubInstance _hubInstance;

        public SignalRPublisher(IHubInstance hubInstance)
        {
            _hubInstance = hubInstance;
        }

        public async Task SubscribeAsync(string topic)
        {
            if (_hubInstance.Connection?.State != HubConnectionState.Connected)
            {
                await _hubInstance.StartAsync();
            }
            await _hubInstance.Connection.InvokeAsync(nameof(IHubInvoker<string>.Subscribe), topic);
        }

        public async Task PublishAsync<T>(string topic, IDictionary<string, string> headers, T payload)
        {
            if (_hubInstance.Connection?.State != HubConnectionState.Connected)
            {
                await _hubInstance.StartAsync();
            }

            var type = payload.GetType().AssemblyQualifiedName;
            var message = new Message(type, payload.ToString());

            await _hubInstance.Connection.InvokeAsync(nameof(IHubInvoker<Message>.PublishToTopic),
                topic, headers, message);
        }
    }
}