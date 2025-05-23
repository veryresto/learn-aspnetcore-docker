# Use the official .NET SDK image for build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /app

# Copy csproj and restore
COPY MyApi.csproj ./
RUN dotnet restore MyApi.csproj

# Copy the rest of the app and build
COPY . ./
RUN dotnet publish MyApi.csproj -c Release -o out

# Use a smaller runtime image for running the app
FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app
COPY --from=build /app/out .

EXPOSE 80

ENTRYPOINT ["dotnet", "MyApi.dll"]
