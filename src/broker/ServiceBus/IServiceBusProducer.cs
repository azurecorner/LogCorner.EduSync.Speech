namespace LogCorner.EduSync.Speech.ServiceBus
{
    public interface IServiceBusProducer
    {
        Task SendAsync(string topic, string @event);
    }

    //public class ServiceBusProducer : IServiceBusProducer
    //{
    //    public Task SendAsync(string topic, string @event)
    //    {
    //        throw new NotImplementedException();
    //    }
    //}
}