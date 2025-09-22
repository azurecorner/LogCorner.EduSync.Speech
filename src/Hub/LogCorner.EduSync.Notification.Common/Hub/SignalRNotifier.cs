using LogCorner.EduSync.Notification.Common.Model;
using LogCorner.EduSync.Speech.Command.SharedKernel.Events;
using LogCorner.EduSync.Speech.Command.SharedKernel.Serialyser;
using Microsoft.AspNetCore.SignalR.Client;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace LogCorner.EduSync.Notification.Common.Hub
{
    public class SignalRNotifier : ISignalRNotifier
    {
        public event Action<EventStore> ReceivedOnPublish;

        public event Action<string, IDictionary<string, string>, object> ReceivedOnPublishToTopic;

        private readonly IHubInstance _hubInstance;
        private readonly IJsonSerializer _eventSerializer;

        public SignalRNotifier(IHubInstance hubInstance, IJsonSerializer eventSerializer)
        {
            _hubInstance = hubInstance;
            _eventSerializer = eventSerializer;
        }

        public async Task StartAsync()
        {
            if (_hubInstance.Connection?.State != HubConnectionState.Connected)
            {
                await _hubInstance.StartAsync();
            }
        }

        public async Task OnPublish()
        {
            _hubInstance.Connection.On<EventStore>(nameof(IHubNotifier<EventStore>.OnPublish),
                u => ReceivedOnPublish?.Invoke(u));
            await Task.CompletedTask;
        }

        public async Task OnPublish(string topic)
        {
            _hubInstance.Connection.On<string, IDictionary<string, string>, Message>(nameof(IHubNotifier<string>.OnPublish),
                (subject, header, body) =>
                {
                    var payload = _eventSerializer.Deserialize<object>(body.Type, body.Body);
                    ReceivedOnPublishToTopic?.Invoke(subject, header, payload);
                });
            await Task.CompletedTask;
        }

        public async Task StopAsync()
        {
            await _hubInstance.StopAsync();
        }
    }
}