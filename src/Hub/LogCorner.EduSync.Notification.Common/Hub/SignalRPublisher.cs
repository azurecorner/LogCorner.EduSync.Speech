using LogCorner.EduSync.Notification.Common.Model;
using LogCorner.EduSync.Speech.Command.SharedKernel.Serialyser;
using Microsoft.AspNetCore.SignalR.Client;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace LogCorner.EduSync.Notification.Common.Hub
{
    public class SignalRPublisher : ISignalRPublisher
    {
        private readonly IHubInstance _hubInstance;
        private readonly IJsonSerializer _eventSerializer;

        public SignalRPublisher(IHubInstance hubInstance, IJsonSerializer eventSerializer)
        {
            _hubInstance = hubInstance;
            _eventSerializer = eventSerializer;
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

            var serializedBody = _eventSerializer.Serialize(payload);

            var type = payload.GetType().AssemblyQualifiedName;
            var message = new Message(type, serializedBody);

            await _hubInstance.Connection.InvokeAsync(nameof(IHubInvoker<Message>.PublishToTopic),
                topic, headers, message);
        }
    }
}