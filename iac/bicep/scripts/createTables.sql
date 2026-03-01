USE [LogCorner.EduSync.Speech.Database]
GO
CREATE TABLE [dbo].[Speech] (
    [ID]          UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [Title]       NVARCHAR (250)   NOT NULL,
    [Description] NVARCHAR (MAX)   NOT NULL,
    [Url]         NVARCHAR (250)   NOT NULL,
    [Type]        INT              DEFAULT ((1)) NOT NULL,
    [IsDeleted]   BIT              DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Presentation] PRIMARY KEY CLUSTERED ([ID] ASC)
);

GO
CREATE TABLE [dbo].[MediaFile] (
    [ID]       UNIQUEIDENTIFIER NOT NULL,
    [Url]      NVARCHAR (250)   NULL,
    [SpeechID] UNIQUEIDENTIFIER NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MediaFile_Speech] FOREIGN KEY ([SpeechID]) REFERENCES [dbo].[Speech] ([ID])
);


GO
CREATE TABLE [dbo].[EventStore] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [Version]     BIGINT           NOT NULL,
    [AggregateId] UNIQUEIDENTIFIER NOT NULL,
    [Name]        NVARCHAR (250)   NOT NULL,
    [TypeName]    NVARCHAR (250)   NOT NULL,
    [OccurredOn]  DATETIME         NOT NULL,
    [PayLoad]     TEXT             NOT NULL,
    CONSTRAINT [PK__EventStore] PRIMARY KEY CLUSTERED ([Id] ASC)
);

