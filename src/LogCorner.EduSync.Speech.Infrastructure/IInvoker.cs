using LogCorner.EduSync.Speech.Domain.SpeechAggregate;

namespace LogCorner.EduSync.Speech.Infrastructure
{
    public interface IInvoker<out T> where T : AggregateRoot<Guid>
    {
        TU CreateInstanceOfAggregateRoot<TU>();
    }
}