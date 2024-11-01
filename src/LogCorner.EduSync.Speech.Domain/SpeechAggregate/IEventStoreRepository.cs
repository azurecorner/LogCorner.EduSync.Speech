using LogCorner.EduSync.Speech.Command.SharedKernel.Events;

namespace LogCorner.EduSync.Speech.Domain.SpeechAggregate
{
    public interface IEventStoreRepository
    {
        Task AppendAsync(EventStore @event);

        Task<TU> GetByIdAsync<TU>(Guid aggregateId) where TU : AggregateRoot<Guid>;
    }
}