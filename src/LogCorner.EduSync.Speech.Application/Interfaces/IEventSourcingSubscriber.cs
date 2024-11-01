using LogCorner.EduSync.Speech.Domain.SpeechAggregate;

namespace LogCorner.EduSync.Speech.Application.Interfaces
{
    public interface IEventSourcingSubscriber
    {
        Task Subscribe(IEventSourcing aggregate);
    }
}