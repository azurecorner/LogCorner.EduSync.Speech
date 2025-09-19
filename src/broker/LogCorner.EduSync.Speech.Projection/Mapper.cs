using LogCorner.EduSync.Speech.Projection;
using System.Collections.Generic;

namespace LogCorner.EduSync.Speech.Repository
{
    public static class Mapper
    {
        //public static Speech? ToSpeech(SpeechProjection projection)
        //{
        //    if (projection == null)
        //        return null;

        //    return new Speech(
        //        projection.Id.ToString(),
        //        projection.Title,
        //        projection.Url,
        //        projection.Description,
        //        projection.Type,
        //        projection.IsDeleted,
        //        projection.Version
        //    );
        //}

        public static object ToSpeech(SpeechProjectionTest projection)
        {
            if (projection == null) return null;

            var obj = new Dictionary<string, object>();

            if (projection?.Id != null) obj["id"] = projection.Id.ToString();
            if (!string.IsNullOrWhiteSpace(projection.Title)) obj["title"] = projection.Title;
            if (!string.IsNullOrWhiteSpace(projection.Url)) obj["url"] = projection.Url;
            if (!string.IsNullOrWhiteSpace(projection.Description)) obj["description"] = projection.Description;
            if (projection.Type != null) obj["type"] = projection.Type;
            if (projection?.IsDeleted != null) obj["isDeleted"] = projection.IsDeleted;
            if (projection?.Version != null) obj["version"] = projection.Version;

            return obj;
        }

    }
}