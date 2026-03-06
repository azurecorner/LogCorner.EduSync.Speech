# See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# This stage is used when running from VS in fast mode (Default for Debug configuration)
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081


# This stage is used to build the service project
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Query/LogCorner.EduSync.Speech.Presentation/LogCorner.EduSync.Speech.Presentation.csproj", "Query/LogCorner.EduSync.Speech.Presentation/"]
COPY ["broker/LogCorner.EduSync.Speech.CosmosDb/LogCorner.EduSync.Speech.CosmosDb.csproj", "broker/LogCorner.EduSync.Speech.CosmosDb/"]
COPY ["Query/LogCorner.EduSync.Speech.Application/LogCorner.EduSync.Speech.Application.csproj", "Query/LogCorner.EduSync.Speech.Application/"]
COPY ["Query/LogCorner.EduSync.Speech.Infrastructure/LogCorner.EduSync.Speech.Infrastructure.csproj", "Query/LogCorner.EduSync.Speech.Infrastructure/"]
COPY ["Query/LogCorner.EduSync.Speech.ReadModel/LogCorner.EduSync.Speech.ReadModel.csproj", "Query/LogCorner.EduSync.Speech.ReadModel/"]
RUN dotnet restore "./Query/LogCorner.EduSync.Speech.Presentation/LogCorner.EduSync.Speech.Presentation.csproj"
COPY . .
WORKDIR "/src/Query/LogCorner.EduSync.Speech.Presentation"
RUN dotnet build "./LogCorner.EduSync.Speech.Presentation.csproj" -c $BUILD_CONFIGURATION -o /app/build

# This stage is used to publish the service project to be copied to the final stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./LogCorner.EduSync.Speech.Presentation.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# This stage is used in production or when running from VS in regular mode (Default when not using the Debug configuration)
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "LogCorner.EduSync.Speech.Presentation.dll"]