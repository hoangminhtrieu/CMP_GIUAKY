FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src
COPY ["src/TrieuHiNeCon.Web.Host/TrieuHiNeCon.Web.Host.csproj", "src/TrieuHiNeCon.Web.Host/"]
COPY ["src/TrieuHiNeCon.Web.Core/TrieuHiNeCon.Web.Core.csproj", "src/TrieuHiNeCon.Web.Core/"]
COPY ["src/TrieuHiNeCon.Application/TrieuHiNeCon.Application.csproj", "src/TrieuHiNeCon.Application/"]
COPY ["src/TrieuHiNeCon.Core/TrieuHiNeCon.Core.csproj", "src/TrieuHiNeCon.Core/"]
COPY ["src/TrieuHiNeCon.EntityFrameworkCore/TrieuHiNeCon.EntityFrameworkCore.csproj", "src/TrieuHiNeCon.EntityFrameworkCore/"]
WORKDIR "/src/src/TrieuHiNeCon.Web.Host"
RUN dotnet restore 

WORKDIR /src
COPY ["src/TrieuHiNeCon.Web.Host", "src/TrieuHiNeCon.Web.Host"]
COPY ["src/TrieuHiNeCon.Web.Core", "src/TrieuHiNeCon.Web.Core"]
COPY ["src/TrieuHiNeCon.Application", "src/TrieuHiNeCon.Application"]
COPY ["src/TrieuHiNeCon.Core", "src/TrieuHiNeCon.Core"]
COPY ["src/TrieuHiNeCon.EntityFrameworkCore", "src/TrieuHiNeCon.EntityFrameworkCore"]
WORKDIR "/src/src/TrieuHiNeCon.Web.Host"
RUN dotnet publish -c Release -o /publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0
EXPOSE 80
WORKDIR /app
COPY --from=build /publish .
ENTRYPOINT ["dotnet", "TrieuHiNeCon.Web.Host.dll"]
