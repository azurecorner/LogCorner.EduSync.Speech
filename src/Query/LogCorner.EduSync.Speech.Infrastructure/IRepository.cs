using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace LogCorner.EduSync.Speech.Infrastructure
{
    public interface IRepository
    {
        Task<T?> TryReadItemAsync<T>(string id, Func<string, Task> writeOutputAsync);

        Task<List<T>> ReadAsync<T>(Func<string, Task> writeOutputAync);
    }
}