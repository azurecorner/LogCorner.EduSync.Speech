# See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# This stage is used when running from VS in fast mode (Default for Debug configuration)
FROM mcr.microsoft.com/dotnet/runtime:9.0 AS base
USER $APP_UID
WORKDIR /app


# This stage is used to build the service project
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["broker/LogCorner.EduSync.Speech.WorkerService/LogCorner.EduSync.Speech.WorkerService.csproj", "broker/LogCorner.EduSync.Speech.WorkerService/"]
COPY ["broker/LogCorner.EduSync.Speech.Consumer/LogCorner.EduSync.Speech.Consumer.csproj", "broker/LogCorner.EduSync.Speech.Consumer/"]
COPY ["Hub/LogCorner.EduSync.Notification.Common/LogCorner.EduSync.Notification.Common.csproj", "Hub/LogCorner.EduSync.Notification.Common/"]
COPY ["Command/LogCorner.EduSync.Speech.SharedKernel/LogCorner.EduSync.Speech.SharedKernel.csproj", "Command/LogCorner.EduSync.Speech.SharedKernel/"]
COPY ["broker/LogCorner.EduSync.Speech.CosmosDb/LogCorner.EduSync.Speech.CosmosDb.csproj", "broker/LogCorner.EduSync.Speech.CosmosDb/"]
COPY ["broker/LogCorner.EduSync.Speech.Projection/LogCorner.EduSync.Speech.Repository.csproj", "broker/LogCorner.EduSync.Speech.Projection/"]
COPY ["broker/ServiceBus/LogCorner.EduSync.Speech.ServiceBus.csproj", "broker/ServiceBus/"]
RUN dotnet restore "./broker/LogCorner.EduSync.Speech.WorkerService/LogCorner.EduSync.Speech.WorkerService.csproj"
COPY . .
WORKDIR "/src/broker/LogCorner.EduSync.Speech.WorkerService"
RUN dotnet build "./LogCorner.EduSync.Speech.WorkerService.csproj" -c $BUILD_CONFIGURATION -o /app/build

# This stage is used to publish the service project to be copied to the final stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./LogCorner.EduSync.Speech.WorkerService.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# This stage is used in production or when running from VS in regular mode (Default when not using the Debug configuration)
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "LogCorner.EduSync.Speech.WorkerService.dll"]