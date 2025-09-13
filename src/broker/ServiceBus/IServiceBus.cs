using LogCorner.EduSync.Speech.Command.SharedKernel.Events;

namespace LogCorner.EduSync.Speech.ServiceBus
{
    public interface IServiceBus
    {
        Task SendAsync(string topic, EventStore @event);

        Task ReceiveAsync(string[] topics, CancellationToken stoppingToken);
    }

    public interface IAzureServiceBus
    {
        Task SendMessage<T>(T message);

        Task<List<T>> ReceiveMessage<T>();
    }

    public interface IServiceBusProvider
    {
        Task SendAsync(string topic, EventStore @event);

        Task ReceiveAsync(string[] topic, CancellationToken stoppingToken, bool runAlawys = true);
    }
}