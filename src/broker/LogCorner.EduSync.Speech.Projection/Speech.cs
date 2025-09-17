using LogCorner.EduSync.Speech.Command.SharedKernel;

namespace LogCorner.EduSync.Speech.Repository
{
    public class Speech
    {
        public string id { get; private set; }
        public string title { get; private set; }

        public string url { get; private set; }
        public string description { get; private set; }
        public SpeechTypeEnum type { get; private set; }

        public bool isDeleted { get; private set; }

        public long version { get; private set; }

        public Speech(string id, string title, string url, string description, SpeechTypeEnum type, bool isDeleted, long version)
        {
            this.id = id;
            this.title = title;
            this.url = url;
            this.description = description;
            this.type = type;
            this.isDeleted = isDeleted;
            this.version = version;
        }
    }
}