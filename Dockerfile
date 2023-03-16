FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 5107

ENV ASPNETCORE_URLS=http://+:5107

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["azscale.csproj", "./"]
RUN dotnet restore "azscale.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "azscale.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "azscale.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "azscale.dll"]
