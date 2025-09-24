namespace LogCorner.EduSync.Speech.Presentation
{
    public class StartupTask : IHostedService
    {
        private readonly IServiceProvider _serviceProvider;

        public StartupTask(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        public async Task StartAsync(CancellationToken cancellationToken)
        {
            using var scope = _serviceProvider.CreateScope();
            var myService = scope.ServiceProvider.GetRequiredService<IMyService>();
            await myService.DoWorkAsync();
        }

        public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
    }

    public interface IMyService
    {
        Task DoWorkAsync();
    }

    public class MyService : IMyService
    {
        public Task DoWorkAsync()
        {
            throw new NotImplementedException();
        }
    }
}