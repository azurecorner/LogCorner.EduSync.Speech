namespace Logistic.Infrastructure.cosmos
{
    public record AzureCosmosDB
    {
        public required string Endpoint { get; init; }

        public required string DatabaseName { get; init; }

        public required string ContainerName { get; init; }
    }
}