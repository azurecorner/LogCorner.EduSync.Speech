using Azure.Identity;
using Azure.Messaging.ServiceBus;
using LogCorner.EduSync.Speech.Command.SharedKernel.Serialyser;
using Microsoft.Extensions.Configuration;
using System.Net.Mime;

namespace LogCorner.EduSync.Speech.ServiceBus
{
    public class AzureServiceBus : IServiceBusProducer, IServiceBusReceiver
    {
        // https://learn.microsoft.com/en-us/dotnet/api/overview/azure/identity-readme?view=azure-dotnet
        // name of your Service Bus queue
        // the client that owns the connection and can be used to create senders and receivers
        private ServiceBusClient client;

        // the sender used to publish messages to the queue
        private ServiceBusSender sender;

        // number of messages to be sent to the queue
        private const int numOfMessages = 3;

        //private readonly IEventSerializer _eventSerializer;
        private readonly IJsonSerializer _jsonSerializer;

        // the processor that reads and processes messages from the queue
        private ServiceBusProcessor processor;

        private string serviceBusNamespace;
        private string serviceBusQueueName;

        public IConfiguration Configuration { get; }

        public AzureServiceBus(IEventSerializer eventSerializer, IJsonSerializer jsonSerializer, IConfiguration configuration)
        {
            _jsonSerializer = jsonSerializer;
            Configuration = configuration;

            var userAssignedClientId = Configuration["UserAssignedClientId"];// ?? throw new ArgumentNullException(nameof(Configuration), "UserAssignedClientId configuration is missing.");
            var tenantId = Configuration["TenantId"];

            Console.WriteLine($"*******************-UserAssignedClientId: {userAssignedClientId}");

            serviceBusNamespace = Configuration["ServiceBusNamespace"] ?? throw new ArgumentNullException(nameof(Configuration), "ServiceBusNamespace configuration is missing.");
            serviceBusQueueName = Configuration["ServiceBusQueueName"] ?? throw new ArgumentNullException(nameof(Configuration), "ServiceBusQueueName configuration is missing.");

            var clientOptions = new ServiceBusClientOptions()
            {
                TransportType = ServiceBusTransportType.AmqpWebSockets
            };

            Console.WriteLine($"*******************-ASPNETCORE_ENVIRONMENT = {Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")}");

            var managedIdentityClientId = Environment.GetEnvironmentVariable("AZURE_CLIENT_ID") ?? userAssignedClientId;
            var azureTenantId = Environment.GetEnvironmentVariable("AZURE_TENANT_ID") ?? tenantId;

            Console.WriteLine("AZURE_CLIENT_ID = ", managedIdentityClientId);
            Console.WriteLine("AZURE_TENANT_ID = ", azureTenantId);

            // For example, will discover Visual Studio or Azure CLI credentials
            // in local environments and managed identity credentials in production deployments
            var credential = new DefaultAzureCredential(
                new DefaultAzureCredentialOptions
                {
                    ManagedIdentityClientId = managedIdentityClientId,
                    TenantId = azureTenantId
                }
            );

            var AZURE_CLIENT_ID = Environment.GetEnvironmentVariable("AZURE_CLIENT_ID");
            Console.WriteLine($"*******************-AZURE_CLIENT_ID = {AZURE_CLIENT_ID}");

            var AZURE_TENANT_ID = Environment.GetEnvironmentVariable("AZURE_TENANT_ID");
            Console.WriteLine($"*******************-AZURE_TENANT_ID = {AZURE_TENANT_ID}");

            var AZURE_CLIENT_SECRET = Environment.GetEnvironmentVariable("AZURE_CLIENT_SECRET");
            Console.WriteLine($"*******************-AZURE_CLIENT_SECRET = {AZURE_CLIENT_SECRET}");

            //       var token = await credential.GetTokenAsync(
            //new TokenRequestContext(new[] { "https://servicebus.azure.net/.default" }), CancellationToken.None);

            //Console.WriteLine($"*******************-Token acquired: {token.Token}");

            client = new ServiceBusClient(serviceBusNamespace, credential, clientOptions);
        }

        public async Task SendAsync(string topic, string @event)
        {
            sender = client.CreateSender(serviceBusQueueName);

            // create a batch
            using ServiceBusMessageBatch messageBatch = await sender.CreateMessageBatchAsync();

            // try adding a message to the batch
            var messageBus = new ServiceBusMessage
            {
                Body = new BinaryData(@event),
                MessageId = Guid.NewGuid().ToString(),
                ContentType = MediaTypeNames.Application.Json,
                Subject = "EventSubject"
            };
            if (!messageBatch.TryAddMessage(messageBus))
            {
                // if it is too large for the batch
                throw new Exception($"The message is too large to fit in the batch.");
            }
            // Before sending the message to the service bus
            var MessageProperties = string.Join(", ", messageBus.ApplicationProperties.Select(kv => $"{kv.Key}: {kv.Value}"));
            Console.WriteLine($" messageBus.ApplicationProperties before Injecting trace context into message. Message properties: {MessageProperties}");

            // Use the producer client to send the batch of messages to the Service Bus queue
            await sender.SendMessagesAsync(messageBatch);

            Console.WriteLine($"*******************-A batch of {numOfMessages} messages has been published to the queue.");
        }

        public async Task<List<T>> ReceiveAsync<T>(string[] topics, CancellationToken stoppingToken, bool runAlways = true)
        {
            var messages = new List<T>();

            Console.WriteLine($"*******************-Receiving messages from queue: {serviceBusQueueName}");
            var receiver = client.CreateReceiver(serviceBusQueueName);

            try
            {
                var receivedMessages = await receiver.ReceiveMessagesAsync(
                    maxMessages: 10,
                    maxWaitTime: TimeSpan.FromMilliseconds(100), // ⚡ Reduced to 100ms for faster response
                    cancellationToken: stoppingToken);

                if (receivedMessages.Any())
                {
                    Console.WriteLine($"*******************-Received {receivedMessages.Count} message(s)");
                }

                foreach (var msg in receivedMessages)
                {
                    var body = msg.Body.ToString();
                    var message = _jsonSerializer.Deserialize<T>(body);

                    if (message != null)
                        messages.Add(message);

                    await receiver.CompleteMessageAsync(msg, stoppingToken);
                }
            }
            finally
            {
                await receiver.DisposeAsync();
            }

            return messages;
        }
    }
}