using LogCorner.EduSync.Speech.Command.SharedKernel;
using Microsoft.Extensions.DependencyInjection;

namespace LogCorner.EduSync.Speech.ServiceBus
{
    public static class ServicesConfiguration
    {
        public static void AddServiceBus(this IServiceCollection services/*, IConfiguration configuration*/)
        {
            //  services.AddMediatR(Assembly.GetExecutingAssembly());
            //  services.AddTransient<INotifierMediatorService, NotifierMediatorService>();
            services.AddSharedKernel();
            //services.AddSingleton<IKafkaClusterManager, KafkaClusterManager>();
            //services.AddSingleton<IKafkaClusterManager, KafkaClusterManager>();
            //services.AddResiliencyServices();
            //services.AddOpenTelemetry(configuration);

            //services.AddSingleton<IServiceBusReceiver>(x =>
            //    {
            //        var consumerConfig = new ConsumerConfig
            //        {
            //            BootstrapServers = bootstrapServer,
            //            EnableAutoCommit = false,
            //            EnableAutoOffsetStore = false,
            //            MaxPollIntervalMs = 300000,
            //            GroupId = "default",

            //            // Read messages from start if no commit exists.
            //            AutoOffsetReset = AutoOffsetReset.Earliest
            //        };

            //        var consumer = new ConsumerBuilder<Null, string>(consumerConfig)
            //            .SetKeyDeserializer(Deserializers.Null)
            //            .SetValueDeserializer(Deserializers.Utf8)
            //            .SetErrorHandler((_, e) =>
            //                 Console.WriteLine($"Error: {e.Reason}"))
            //            .Build();

            //        return new KafkaReceiver(
            //            consumer,
            //            x.GetRequiredService<INotifierMediatorService>(), x.GetRequiredService<ITraceService>(),
            //            x.GetRequiredService<ILogger<KafkaReceiver>>(), configuration);
            //    }
            //);

            services.AddSingleton<IServiceBusProducer, AzureServiceBus>();
            services.AddSingleton<IServiceBusReceiver, AzureServiceBus>();
        }
    }
}