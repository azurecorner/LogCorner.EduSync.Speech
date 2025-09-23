using LogCorner.EduSync.Speech.Consumer;

namespace LogCorner.EduSync.Speech.WorkerService
{
    public class Worker : BackgroundService
    {
        private readonly ILogger<Worker> _logger;
        private readonly IConsumerService _consumerService;

        public Worker(ILogger<Worker> logger, IConsumerService consumerService)
        {
            _logger = logger;
            _consumerService = consumerService;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            //while (!stoppingToken.IsCancellationRequested)
            //{
            await _consumerService.DoWorkAsync(stoppingToken);
            _logger.LogInformation("ConsumerService is running .....");

            // You can adjust the delay time based on message frequency and business requirements
            /*   await Task.Delay(3000, stoppingToken); // Delay for 3 seconds before checking for new messages
           }*/
        }
    }
}