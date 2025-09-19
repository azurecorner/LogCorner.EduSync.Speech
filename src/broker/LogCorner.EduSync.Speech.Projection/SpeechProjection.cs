using LogCorner.EduSync.Speech.Command.SharedKernel;
using LogCorner.EduSync.Speech.Command.SharedKernel.Events;
using System;

namespace LogCorner.EduSync.Speech.Projection
{
    public class SpeechProjection : Projection<Guid>
    {
        public string Title { get; private set; }

        public string Url { get; private set; }
        public string Description { get; private set; }
        public SpeechTypeEnum Type { get; private set; }

        public bool IsDeleted { get; private set; }

        private SpeechProjection()
        { }

        public void Apply(SpeechCreatedEvent ev)
        {
            Id = ev.AggregateId;
            Title = ev.Title;
            Url = ev.Url;
            Description = ev.Description;
            Type = ev.Type;
        }

        public void Apply(SpeechTitleChangedEvent ev)
        {
            Id = ev.AggregateId;
            Title = ev.Title;
        }

        public void Apply(SpeechDescriptionChangedEvent ev)
        {
            Id = ev.AggregateId;
            Description = ev.Description;
        }

        public void Apply(SpeechUrlChangedEvent ev)
        {
            Id = ev.AggregateId;
            Url = ev.Url;
        }

        public void Apply(SpeechTypeChangedEvent ev)
        {
            Id = ev.AggregateId;
            Type = ev.Type;
        }

        public void Apply(SpeechDeletedEvent ev)
        {
            Id = ev.AggregateId;
            IsDeleted = ev.IsDeleted;
        }
    }

    public class SpeechProjectionTest : Projection<Guid>
    {
        public string Title { get; private set; }

        public string Url { get; private set; }
        public string Description { get; private set; }
        public SpeechTypeEnum Type { get; private set; }

        public new long Version { get; private set; }

        public bool IsDeleted { get; private set; }

        public SpeechProjectionTest(Guid id, string title, string description, string url, SpeechTypeEnum type, long version, bool isDeleted)
        {
            Id = id;
            Title = title;
            Url = url;
            Description = description;
            Type = type;
            IsDeleted = isDeleted;
            Version = version;
        }
    }
}