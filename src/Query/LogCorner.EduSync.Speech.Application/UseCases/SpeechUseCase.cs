using LogCorner.EduSync.Speech.Infrastructure;
using LogCorner.EduSync.Speech.ReadModel.SpeechReadModel;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace LogCorner.EduSync.Speech.Application.UseCases
{
    public class SpeechUseCase : ISpeechUseCase
    {
        private readonly IRepository _repo;

        public SpeechUseCase(IRepository repo)
        {
            _repo = repo;
        }

        public async Task<IEnumerable<SpeechView>> Handle()
        {
            return await _repo.ReadAsync<SpeechView>(Console.Out.WriteLineAsync);
        }

        public async Task<SpeechView> Handle(Guid id)
        {
            return await _repo.TryReadItemAsync<SpeechView>(id.ToString(), Console.Out.WriteLineAsync)
                ?? throw new KeyNotFoundException($"Speech with id '{id}' was not found.");
        }
    }
}