using OpenAI.Chat;
using Azure;
using Azure.AI.OpenAI;

var endpoint = new Uri("https://datasynchro-openai.cognitiveservices.azure.com/");
var deploymentName = "gpt-4.1-mini";
var apiKey = "4K8LHxL4H1aH7t3NRPPlXj8HRZC2gmqayLFYyYcVt2MwU10VUPmDJQQJ99CCACYeBjFXJ3w3AAAAACOGIyj9";

AzureOpenAIClient azureClient = new(
    endpoint,
    new AzureKeyCredential(apiKey));
ChatClient chatClient = azureClient.GetChatClient(deploymentName);

var requestOptions = new ChatCompletionOptions()
{
   // MaxCompletionTokens = 13107,
    Temperature = 1.0f,
    TopP = 1.0f,
    FrequencyPenalty = 0.0f,
    PresencePenalty = 0.0f,

};

List<ChatMessage> messages = new List<ChatMessage>()
{
    new SystemChatMessage("You are a helpful assistant."),
    new UserChatMessage("I am going to Paris, what should I see?"),
};

var response = chatClient.CompleteChat(messages, requestOptions);
System.Console.WriteLine(response.Value.Content[0].Text);

Console.ReadLine();