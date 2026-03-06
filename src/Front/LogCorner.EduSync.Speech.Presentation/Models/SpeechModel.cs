namespace LogCorner.EduSync.Speech.Presentation.Models
{
    public class SpeechModel
    {
        public string Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Url { get; set; }
        public SpeechType Type { get; set; }
        public int Version { get; set; }
    }
}