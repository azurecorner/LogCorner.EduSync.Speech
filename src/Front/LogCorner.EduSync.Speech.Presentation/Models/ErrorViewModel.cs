namespace LogCorner.EduSync.Speech.Presentation.Models
{
    public class ErrorViewModel
    {
        public string? RequestId { get; set; }

        public bool ShowRequestId => !string.IsNullOrEmpty(RequestId);
    }

    public class SpeechModel
    {
        public string Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Url { get; set; }
        public int? TypeId { get; set; }
        public SpeechType Type { get; set; }
        public int Version { get; set; }
    }

    public class SpeechType
    {
        public int Value { get; set; }
        public string Name { get; set; }
    }
}