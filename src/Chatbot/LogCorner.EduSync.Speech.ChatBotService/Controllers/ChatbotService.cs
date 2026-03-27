using Azure.AI.OpenAI;
using Azure.Identity;
using OpenAI.Chat;
using System.Text;

namespace LogCorner.EduSync.Speech.ChatBotService.Controllers
{
    public class ChatbotService : IAsyncDisposable
    {
        private readonly ChatClient _chatClient;

        public ChatbotService(IConfiguration Configuration)
        {
            var openAiEndpointString = Configuration["OpenAiEndpoint"] 
                ?? throw new InvalidOperationException("OpenAiEndpoint configuration is missing.");

            var openAiEndpoint = new Uri(openAiEndpointString);
            
            var deploymentName = Configuration["DeploymentName"] 
                ?? throw new InvalidOperationException("DeploymentName configuration is missing.");

            var userAssignedClientId = Configuration["UserAssignedClientId"];
            var tenantId = Configuration["TenantId"];

            var managedIdentityClientId = Environment.GetEnvironmentVariable("AZURE_CLIENT_ID") ?? userAssignedClientId;
            var azureTenantId = Environment.GetEnvironmentVariable("AZURE_TENANT_ID") ?? tenantId;

            var credential = new DefaultAzureCredential(
                       new DefaultAzureCredentialOptions
                       {
                           ManagedIdentityClientId = managedIdentityClientId ,// workload-managed-identity
                           TenantId = azureTenantId
                       }
                   );
            AzureOpenAIClient azureClient = new(openAiEndpoint, credential);
            _chatClient = azureClient.GetChatClient(deploymentName);
        }

        public ValueTask DisposeAsync()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Accepts a userId and user message, returns assistant reply text.
        /// Conversation history is preserved per user (in-memory).
        /// </summary>
        public async Task<string> GetReplyAsync(string userId, string userMessage, CancellationToken cancellationToken)
        {
            Console.WriteLine("Interactive Chatbot started. Type your question and press Enter.");
            Console.WriteLine("Type /exit to quit, /reset to clear conversation.");

            var conversation = new List<ChatMessage>
            {
                new SystemChatMessage("You are an AI assistant that helps people find information.")
            };

            Console.Write("> ");
            var userInput = userMessage;
            if (userInput == null)
            {
                return string.Empty; // Fix: return a string if userInput is null
            }

            conversation.Add(ChatMessage.CreateUserMessage(userInput));

            var options = new ChatCompletionOptions
            {
                Temperature = 0.7f,
                TopP = 0.95f,
                FrequencyPenalty = 0f,
                PresencePenalty = 0f,
                MaxOutputTokenCount = 2048
            };

            try
            {
                ChatCompletion completion = await _chatClient.CompleteChatAsync(conversation, options, cancellationToken);

                if (completion != null && completion.Content != null && !string.IsNullOrWhiteSpace(completion.Content.ToString()))
                {
                    Console.WriteLine();
                    Console.WriteLine("Assistant:");
                    var responseBuilder = new StringBuilder();
                    foreach (var item in completion.Content)
                    {
                        Console.Write(item.Text);
                        responseBuilder.Append(item.Text);
                    }
                    Console.WriteLine();

                    conversation.Add(ChatMessage.CreateAssistantMessage(completion.Content.ToString()));
                    return responseBuilder.ToString(); // Fix: return the assistant's reply
                }
                else
                {
                    Console.WriteLine("No response received from the model.");
                    return string.Empty; // Fix: return a string if no response
                }
            }
            catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
            {
                return string.Empty; // Fix: return a string on cancellation
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                return string.Empty; // Fix: return a string on error
            }
        }
    }
}