using System;
using System.Runtime.Serialization;

namespace LogCorner.EduSync.Notification.Common.Exceptions
{
    [Serializable]
    public class NotificationServerException : Exception
    {
        public NotificationServerException(string message) : base(message)
        {
        }

        protected NotificationServerException(SerializationInfo info, StreamingContext context) : base(info, context)
        {
        }
    }
}