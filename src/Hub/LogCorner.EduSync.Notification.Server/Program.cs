using Azure.Identity;
using LogCorner.EduSync.Notification.Common.Exceptions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;

namespace LogCorner.EduSync.Notification.Server
{
    public static class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        private static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureAppConfiguration((context, config) =>
                {
                    var settings = config.Build();

                    if (!bool.TryParse(settings["isAuthenticationEnabled"], out var isAuthenticationEnabled))
                    {
                        throw new NotificationServerException("isAuthenticationEnabled property should be configured appSettings");
                    }
                    if (!context.HostingEnvironment.IsDevelopment() && isAuthenticationEnabled)
                    {
                        // Configure Azure Key Vault Connection
                        var uri = settings["AzureKeyVault:Uri"];
                        var tenantId = settings["AzureKeyVault:tenantId"];
                        var clientId = settings["AzureKeyVault:ClientId"];
                        var clientSecret = settings["AzureKeyVault:ClientSecret"];
                        if (!string.IsNullOrWhiteSpace(uri))

                            config.AddAzureKeyVault(
                                new Uri(uri),
                                new ClientSecretCredential(tenantId, clientId, clientSecret)
                            );
                    }
                })
                .ConfigureLogging((context, loggingBuilder) =>
                {
                    loggingBuilder.ClearProviders();
                    loggingBuilder.AddConsole();
                    //loggingBuilder.AddSerilog(context.Configuration);
                    //loggingBuilder.AddOpenTelemetry(context.Configuration);
                })
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                });
    }
}