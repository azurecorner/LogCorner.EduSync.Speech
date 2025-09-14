using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace LogCorner.EduSync.Speech.CosmosDb
{
    public static class ServicesConfiguration
    {
        public static IServiceCollection RegisterCosmosDependencies(this IServiceCollection services, IConfiguration Configuration)
        {
            var connectionString = Configuration["AzureCosmosDB:ConnectionString"];
            services.AddSingleton<CosmosClient>((serviceProvider) =>
            {
                CosmosClient client = new(
                    connectionString: connectionString
                );
                return client;
            });

            services.AddTransient<IDataService, DataService>();

            return services;
        }
    }
}