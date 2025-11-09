using Azure.Identity;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace LogCorner.EduSync.Speech.CosmosDb
{
    public static class ServicesConfiguration
    {
        public static IServiceCollection RegisterCosmosDependencies(this IServiceCollection services, IConfiguration Configuration)
        {
            services.AddSingleton(sp =>
            {
                CosmosClientOptions cosmosClientOptions = new CosmosClientOptions
                {
                    MaxRetryAttemptsOnRateLimitedRequests = 3,
                    MaxRetryWaitTimeOnRateLimitedRequests = TimeSpan.FromSeconds(60)
                };

                var userAssignedClientId = Configuration["UserAssignedClientId"];
                var tenantId = Configuration["TenantId"];

                var managedIdentityClientId = Environment.GetEnvironmentVariable("AZURE_CLIENT_ID") ?? userAssignedClientId;
                var azureTenantId = Environment.GetEnvironmentVariable("AZURE_TENANT_ID") ?? tenantId;

                Console.WriteLine("AZURE_CLIENT_ID = ", managedIdentityClientId);
                Console.WriteLine("AZURE_TENANT_ID = ", azureTenantId);

                // For example, will discover Visual Studio or Azure CLI credentials
                // in local environments and managed identity credentials in production deployments

                var credential = new DefaultAzureCredential();
                if (!string.IsNullOrEmpty(managedIdentityClientId) && !string.IsNullOrEmpty(azureTenantId))
                {
                    credential = new DefaultAzureCredential(
                       new DefaultAzureCredentialOptions
                       {
                           ManagedIdentityClientId = managedIdentityClientId,
                           TenantId = azureTenantId
                       }
                   );
                }

                return new CosmosClient(Configuration["CosmosDbEndpoint"], credential, cosmosClientOptions);
            });
            return services;
        }
    }
}