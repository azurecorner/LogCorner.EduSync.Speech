using System;
using System.Runtime.Serialization;

namespace LogCorner.EduSync.Notification.Common.Exceptions
{
    [Serializable]
    public class HubConnectedUserException : Exception
    {
        public HubConnectedUserException(string message) : base(message)
        {
        }

        protected HubConnectedUserException(SerializationInfo info, StreamingContext context) : base(info, context)
        {
        }
    }
}