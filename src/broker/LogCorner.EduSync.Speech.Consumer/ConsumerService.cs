using LogCorner.EduSync.Speech.Command.SharedKernel.Events;
using LogCorner.EduSync.Speech.Command.SharedKernel.Serialyser;
using LogCorner.EduSync.Speech.CosmosDb;
using LogCorner.EduSync.Speech.Projection;
using LogCorner.EduSync.Speech.Repository;
using LogCorner.EduSync.Speech.ServiceBus;
using Microsoft.Extensions.Logging;

namespace LogCorner.EduSync.Speech.Consumer;

public class ConsumerService : IConsumerService
{
    private readonly IServiceBusReceiver _serviceBus;
    private readonly ILogger<ConsumerService> _logger;
    private readonly IDataService _dataService;

    private readonly IEventSerializer _eventSerializer;
    private readonly IJsonSerializer _jsonSerializer;

    public ConsumerService(IServiceBusReceiver serviceBus, ILogger<ConsumerService> logger, IDataService dataService, IEventSerializer eventSerializer)
    {
        _serviceBus = serviceBus;
        _logger = logger;
        _dataService = dataService;
        _eventSerializer = eventSerializer;
    }

    public async Task DoWorkAsync(CancellationToken stoppingToken)
    {
        var topics = new[] { "speech", "synchro" };

        var result = await _serviceBus.ReceiveAsync<EventStore>(topics, stoppingToken);
        foreach (var item in result)
        {
            _logger.LogInformation($"Received message - Id: {item.Id}, Client: {item.Name}, WeightKg: {item.AggregateId}, Status: {item.PayLoad}");
            var @event = _eventSerializer.DeserializeEvent<Event>(item.PayLoad, item.TypeName);

            var projection = Invoker.CreateInstanceOfProjection<SpeechProjection>();
            projection.Project(@event);

            var speech = Mapper.ToSpeech(projection);

            if (speech == null)
            {
                _logger.LogWarning("Mapper.ToSpeech returned null for projection");
                return;
            }

            // Process the delivery message (passing it to your data service)
            await _dataService.CreateAsync<LogCorner.EduSync.Speech.Repository.Speech>(async (message) =>
            {
                _logger.LogInformation("Processing message: {message}", message);
            }, speech, speech.id);
        }
    }
}