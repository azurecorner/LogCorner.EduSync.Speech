using System.Threading.Tasks;

namespace LogCorner.EduSync.Speech.Application.Interfaces
{
    public interface IEventPublisher
    {
        public interface IEventPublisher
        {
            Task PublishAsync(string topic, string @event);
        }
    }
}