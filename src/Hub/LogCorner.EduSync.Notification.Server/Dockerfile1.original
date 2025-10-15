#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["LogCorner.EduSync.Notification.Server/LogCorner.EduSync.Notification.Server.csproj", "LogCorner.EduSync.Notification.Server/"]
COPY ["LogCorner.EduSync.Notification.Common/LogCorner.EduSync.Notification.Common.csproj", "LogCorner.EduSync.Notification.Common/"]
RUN dotnet restore "LogCorner.EduSync.Notification.Server/LogCorner.EduSync.Notification.Server.csproj"
COPY . .
WORKDIR "/src/LogCorner.EduSync.Notification.Server"
RUN dotnet build "LogCorner.EduSync.Notification.Server.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "LogCorner.EduSync.Notification.Server.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "LogCorner.EduSync.Notification.Server.dll"]