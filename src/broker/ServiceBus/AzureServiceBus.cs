using Azure.Core;
using Azure.Identity;
using Azure.Messaging.ServiceBus;
using LogCorner.EduSync.Speech.Command.SharedKernel.Events;
using LogCorner.EduSync.Speech.Command.SharedKernel.Serialyser;
using Microsoft.Extensions.Configuration;
using System.Net.Mime;
using System.Text.Json;

using System.Threading.Tasks;
namespace LogCorner.EduSync.Speech.ServiceBus
{

    public class AzureServiceBus : /*IAzureServiceBus */ IServiceBusProducer , IServiceBusReceiver
    {
        // https://learn.microsoft.com/en-us/dotnet/api/overview/azure/identity-readme?view=azure-dotnet
        // name of your Service Bus queue
        // the client that owns the connection and can be used to create senders and receivers
        private ServiceBusClient client;

        // the sender used to publish messages to the queue
        private ServiceBusSender sender;

        // number of messages to be sent to the queue
        private const int numOfMessages = 3;

        private readonly IJsonSerializer _eventSerializer;

        // the processor that reads and processes messages from the queue
        private ServiceBusProcessor processor;

        private string serviceBusNamespace = "datasynchro.servicebus.windows.net";
        private string serviceBusQueueName = "datasyncqueue";
        private string userAssignedClientId; //"ff678d92-8adc-4f90-b8f5-cb4ea1a908ed";

        public IConfiguration Configuration { get; }

        public AzureServiceBus( IJsonSerializer eventSerializer,IConfiguration configuration)
        {
            Configuration = configuration;

            //userAssignedClientId = Configuration["UserAssignedClientId"] ?? throw new ArgumentNullException(nameof(Configuration), "UserAssignedClientId configuration is missing.");

            Console.WriteLine($"*******************-UserAssignedClientId: {userAssignedClientId}");
        }


        public async Task<List<T>> ReceiveMessage<T>()
        {

            List<T> messages = new List<T>();

            var clientOptions = new ServiceBusClientOptions()
            {
                TransportType = ServiceBusTransportType.AmqpWebSockets
            };

            TokenCredential credential;
            Console.WriteLine($"*******************-ASPNETCORE_ENVIRONMENT = {Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")}");

            credential = new DefaultAzureCredential(new DefaultAzureCredentialOptions
            {
                ExcludeManagedIdentityCredential = true
            });

            // Environment variables (you may want to sanitize these in production)
            var AZURE_CLIENT_ID = Environment.GetEnvironmentVariable("AZURE_CLIENT_ID");
            Console.WriteLine($"*******************-AZURE_CLIENT_ID = {AZURE_CLIENT_ID}");
            var AZURE_TENANT_ID = Environment.GetEnvironmentVariable("AZURE_TENANT_ID");
            Console.WriteLine($"*******************-AZURE_TENANT_ID = {AZURE_TENANT_ID}");
            var AZURE_CLIENT_SECRET = Environment.GetEnvironmentVariable("AZURE_CLIENT_SECRET");
            Console.WriteLine($"*******************-AZURE_CLIENT_SECRET = {AZURE_CLIENT_SECRET}");

            // Get token
            var token = await credential.GetTokenAsync(new TokenRequestContext(new[] { "https://servicebus.azure.net/.default" }), CancellationToken.None);

            client = new ServiceBusClient(serviceBusNamespace, credential, clientOptions);
            processor = client.CreateProcessor(serviceBusQueueName, new ServiceBusProcessorOptions());

            try
            {
                // Add handler to process messages
                processor.ProcessMessageAsync += MessageHandler;

                // Add handler to process errors
                processor.ProcessErrorAsync += ErrorHandler;

                // Start processing
                await processor.StartProcessingAsync();

                // Wait for a period before stopping processing (adjust as needed)
                await Task.Delay(TimeSpan.FromSeconds(30));

                // Stop processing after delay
                Console.WriteLine("\nStopping the receiver...");
                await processor.StopProcessingAsync();
                Console.WriteLine("Stopped receiving messages");

                // Return the collected messages
                return messages;
            }
            catch (ServiceBusException ex)
            {
                Console.WriteLine($"*******************-ServiceBusException: {ex.Message}");
                throw;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"*******************-Exception: {ex.Message}");
                throw;
            }
            finally
            {
                await processor.DisposeAsync();
                await client.DisposeAsync();
            }

            // Message handler that processes individual messages
            async Task MessageHandler(ProcessMessageEventArgs args)
            {
                var messageBody = args.Message.Body.ToString();
                Console.WriteLine($"*******************-Received from service bus queue: {messageBody}");

                // Only proceed if the message is not empty
                if (!string.IsNullOrWhiteSpace(messageBody))
                {
                    var message = JsonSerializer.Deserialize<T>(messageBody);
                    if (message != null)
                    {
                        messages.Add(message);  // Add the deserialized message to the list
                    }
                }

                // Complete the message (it will be removed from the queue)
                await args.CompleteMessageAsync(args.Message);



            }
                // Error handler for any issues during message processing
                Task ErrorHandler(ProcessErrorEventArgs args)
                {
                    Console.WriteLine($"Error processing message: {args.Exception.ToString()}");
                    return Task.CompletedTask;
                }
            }

 

        public async Task SendAsync(string topic, string @event)
        {
            var clientOptions = new ServiceBusClientOptions()
            {
                TransportType = ServiceBusTransportType.AmqpWebSockets
            };

            TokenCredential credential;
            Console.WriteLine($"*******************-ASPNETCORE_ENVIRONMENT = {Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")}");

            credential = new DefaultAzureCredential(new DefaultAzureCredentialOptions
            {
                ExcludeManagedIdentityCredential = true
            });
            var AZURE_CLIENT_ID = Environment.GetEnvironmentVariable("AZURE_CLIENT_ID");
            Console.WriteLine($"*******************-AZURE_CLIENT_ID = {AZURE_CLIENT_ID}");

            var AZURE_TENANT_ID = Environment.GetEnvironmentVariable("AZURE_TENANT_ID");
            Console.WriteLine($"*******************-AZURE_TENANT_ID = {AZURE_TENANT_ID}");

            var AZURE_CLIENT_SECRET = Environment.GetEnvironmentVariable("AZURE_CLIENT_SECRET");
            Console.WriteLine($"*******************-AZURE_CLIENT_SECRET = {AZURE_CLIENT_SECRET}");

            var token = await credential.GetTokenAsync(
     new TokenRequestContext(new[] { "https://servicebus.azure.net/.default" }), CancellationToken.None);

            //Console.WriteLine($"*******************-Token acquired: {token.Token}");

            client = new ServiceBusClient(serviceBusNamespace, credential, clientOptions);
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

        public async Task ReceiveAsync(string[] topics, CancellationToken stoppingToken, bool runAlways = true)
        {

            //List<T> messages = new List<T>();

            var clientOptions = new ServiceBusClientOptions()
            {
                TransportType = ServiceBusTransportType.AmqpWebSockets
            };

            TokenCredential credential;
            Console.WriteLine($"*******************-ASPNETCORE_ENVIRONMENT = {Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")}");

            credential = new DefaultAzureCredential(new DefaultAzureCredentialOptions
            {
                ExcludeManagedIdentityCredential = true
            });

            // Environment variables (you may want to sanitize these in production)
            var AZURE_CLIENT_ID = Environment.GetEnvironmentVariable("AZURE_CLIENT_ID");
            Console.WriteLine($"*******************-AZURE_CLIENT_ID = {AZURE_CLIENT_ID}");
            var AZURE_TENANT_ID = Environment.GetEnvironmentVariable("AZURE_TENANT_ID");
            Console.WriteLine($"*******************-AZURE_TENANT_ID = {AZURE_TENANT_ID}");
            var AZURE_CLIENT_SECRET = Environment.GetEnvironmentVariable("AZURE_CLIENT_SECRET");
            Console.WriteLine($"*******************-AZURE_CLIENT_SECRET = {AZURE_CLIENT_SECRET}");

            // Get token
            var token = await credential.GetTokenAsync(new TokenRequestContext(new[] { "https://servicebus.azure.net/.default" }), CancellationToken.None);

            client = new ServiceBusClient(serviceBusNamespace, credential, clientOptions);
            processor = client.CreateProcessor(serviceBusQueueName, new ServiceBusProcessorOptions());

            try
            {
                // Add handler to process messages
                processor.ProcessMessageAsync += MessageHandler;

                // Add handler to process errors
                processor.ProcessErrorAsync += ErrorHandler;

                // Start processing
                await processor.StartProcessingAsync();

                // Wait for a period before stopping processing (adjust as needed)
                await Task.Delay(TimeSpan.FromSeconds(30));

                // Stop processing after delay
                Console.WriteLine("\nStopping the receiver...");
                await processor.StopProcessingAsync();
                Console.WriteLine("Stopped receiving messages");

                // Return the collected messages
                //Console.WriteLine( messages);
            }
            catch (ServiceBusException ex)
            {
                Console.WriteLine($"*******************-ServiceBusException: {ex.Message}");
                throw;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"*******************-Exception: {ex.Message}");
                throw;
            }
            finally
            {
                await processor.DisposeAsync();
                await client.DisposeAsync();
            }

            // Message handler that processes individual messages
            async Task MessageHandler(ProcessMessageEventArgs args)
            {
                var messageBody = args.Message.Body.ToString();
                Console.WriteLine($"*******************-Received from service bus queue: {messageBody}");

                // Only proceed if the message is not empty
                //if (!string.IsNullOrWhiteSpace(messageBody))
                //{
                //    var message = JsonSerializer.Deserialize<T>(messageBody);
                //    if (message != null)
                //    {
                //        messages.Add(message);  // Add the deserialized message to the list
                //    }
                //}

                // Complete the message (it will be removed from the queue)
                await args.CompleteMessageAsync(args.Message);



            }
            // Error handler for any issues during message processing
            Task ErrorHandler(ProcessErrorEventArgs args)
            {
                Console.WriteLine($"Error processing message: {args.Exception.ToString()}");
                return Task.CompletedTask;
            }
        }
    }
    }


