namespace LogCorner.EduSync.Speech.Presentation.Models
{
    public class SpeechModelForCreation
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public string Url { get; set; }

        public int TypeId { get; set; }
        //public SpeechType Type { get; set; }

        public SpeechModelForCreation()
        {
            Title = "this is a title";
            Description = "\"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.\",";
            Url = "http://test.com";
            TypeId = 1; // Default to Conference
        }
    }

    public class SpeechModelForUpdate
    {
        public Guid Id { get; set; }    
        public string Title { get; set; }
        public string Description { get; set; }
        public string Url { get; set; }

        public int TypeId { get; set; }
       
    }
}