using LogCorner.EduSync.Notification.Common.Model;
using LogCorner.EduSync.Speech.Command.SharedKernel.Events;
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

        public SignalRNotifier(IHubInstance hubInstance)
        {
            _hubInstance = hubInstance;
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
                    ReceivedOnPublishToTopic?.Invoke(subject, header, body);
                });
            await Task.CompletedTask;
        }

        public async Task StopAsync()
        {
            await _hubInstance.StopAsync();
        }
    }
}