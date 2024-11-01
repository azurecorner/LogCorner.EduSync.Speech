using LogCorner.EduSync.Speech.Domain.IRepository;

namespace LogCorner.EduSync.Speech.Domain.SpeechAggregate
{
    public interface ISpeechRepository : IRepository<Speech, Guid>
    {
        Task DeleteAsync(Speech speech);
    }
}