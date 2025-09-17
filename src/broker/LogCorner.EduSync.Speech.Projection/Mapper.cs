using LogCorner.EduSync.Speech.Projection;

namespace LogCorner.EduSync.Speech.Repository
{
    public static class Mapper
    {
        public static Speech? ToSpeech(SpeechProjection projection)
        {
            if (projection == null)
                return null;

            return new Speech(
                projection.Id.ToString(),
                projection.Title,
                projection.Url,
                projection.Description,
                projection.Type,
                projection.IsDeleted,
                projection.Version
            );
        }
    }
}