namespace LogCorner.EduSync.Speech.ServiceBus;

public interface IServiceBusReceiver
{
    Task<List<T>> ReceiveAsync<T>(string[] topics, CancellationToken stoppingToken, bool runAlways = true);

}