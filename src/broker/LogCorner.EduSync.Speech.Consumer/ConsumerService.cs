using LogCorner.EduSync.Notification.Common.Hub;
using LogCorner.EduSync.Speech.Command.SharedKernel;
using LogCorner.EduSync.Speech.Command.SharedKernel.Events;
using LogCorner.EduSync.Speech.Command.SharedKernel.Serialyser;
using LogCorner.EduSync.Speech.CosmosDb;
using LogCorner.EduSync.Speech.Projection;
using LogCorner.EduSync.Speech.Repository;
using LogCorner.EduSync.Speech.ServiceBus;
using Microsoft.Extensions.Logging;
using System.Text.Json;

namespace LogCorner.EduSync.Speech.Consumer;

public class ConsumerService : IConsumerService
{
    private readonly IServiceBusReceiver _serviceBus;
    private readonly ILogger<ConsumerService> _logger;
    private readonly IDataService _dataService;

    private readonly IEventSerializer _eventSerializer;
    private readonly ISignalRPublisher _publisher;

    public ConsumerService(IServiceBusReceiver serviceBus, ILogger<ConsumerService> logger, IDataService dataService, IEventSerializer eventSerializer, ISignalRPublisher signalRPublisher)
    {
        _serviceBus = serviceBus;
        _logger = logger;
        _dataService = dataService;
        _eventSerializer = eventSerializer;
        _publisher = signalRPublisher;
    }

    public async Task DoWorkAsync(CancellationToken stoppingToken)
    {
        var topics = new[] { "speech", "synchro" };

        var result = await _serviceBus.ReceiveAsync<EventStore>(topics, stoppingToken);
        foreach (var item in result)
        {
            _logger.LogInformation($"Received message - Id: {item.Id}, Client: {item.Name}, WeightKg: {item.AggregateId}, Status: {item.PayLoad}");
            Console.WriteLine($"Received message - Id: {item.Id}, Client: {item.Name}, WeightKg: {item.AggregateId}, Status: {item.PayLoad}");
            var @event = _eventSerializer.DeserializeEvent<Event>(item.PayLoad, item.TypeName);

            var projection = Invoker.CreateInstanceOfProjection<SpeechProjection>();
            projection.Project(@event);

            var speech = Mapper.ToSpeech(projection);

            if (speech == null)
            {
                _logger.LogWarning("Mapper.ToSpeech returned null for projection");
                Console.WriteLine("Mapper.ToSpeech returned null for projection");
                return;
            }

            if (projection.IsDeleted == false)
            {
                // Process the delivery message (passing it to your data service)
                await _dataService.CreateAsync<object>(async (message) =>
                {
                    _logger.LogInformation("Processing message: {message}", message);
                    Console.WriteLine("Processing message: {0}", message);
                }, speech, projection.Id.ToString());
            }
            else
            {
                await _dataService.DeleteAsync<object>(async (message) =>
                {
                    _logger.LogInformation("Processing message: {message}", message);
                    Console.WriteLine("Processing message: {0}", message);
                }, projection.Id.ToString());
            }
            string jsonString = JsonSerializer.Serialize(projection);
            await _publisher.PublishAsync("ReadModelAcknowledged", null, jsonString);
        }
    }

}