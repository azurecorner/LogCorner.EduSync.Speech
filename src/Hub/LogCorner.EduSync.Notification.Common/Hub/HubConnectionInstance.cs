using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;

namespace LogCorner.EduSync.Notification.Common.Hub
{
    public class HubConnectionInstance : IHubInstance
    {
   
        private readonly string _url;
        public HubConnection Connection { get; private set; }

 
        public HubConnectionInstance(string url)
        {
            _url = url;
         }

        public async Task StartAsync()
        {
        
            Connection = new HubConnectionBuilder()
                .WithUrl(_url)
                .ConfigureLogging(logging =>
                {
                    // This will set ALL logging to Debug level
                    logging.SetMinimumLevel(LogLevel.Debug);
                })

               .WithAutomaticReconnect()
                .Build();

            await Connection.StartAsync();
        }

        public async Task StopAsync()
        {
            if (Connection != null && Connection.State != HubConnectionState.Disconnected)
            {
                await Connection.StopAsync();
            }
        }

    
    }
}