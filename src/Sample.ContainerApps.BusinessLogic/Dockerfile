#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src/Sample.ContainerApps.BusinessLogic
COPY ["Sample.ContainerApps.BusinessLogic.csproj", "Sample.ContainerApps.BusinessLogic_Business/"]
RUN dotnet restore "Sample.ContainerApps.BusinessLogic_Business/Sample.ContainerApps.BusinessLogic.csproj"
COPY . .
WORKDIR "/src/Sample.ContainerApps.BusinessLogic"
RUN dotnet build "Sample.ContainerApps.BusinessLogic.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Sample.ContainerApps.BusinessLogic.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Sample.ContainerApps.BusinessLogic.dll"]