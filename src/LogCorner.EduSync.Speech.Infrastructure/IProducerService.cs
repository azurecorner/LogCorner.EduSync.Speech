using System.Threading.Tasks;

namespace LogCorner.EduSync.Speech.Infrastructure
{
    public interface IProducerService
    {
        Task ProduceAsync(string topic, string @event);
    }
}