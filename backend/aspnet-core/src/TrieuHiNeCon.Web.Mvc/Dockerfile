FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

RUN dotnet tool install -g Microsoft.Web.LibraryManager.Cli
RUN ln -s ~/.dotnet/tools/libman /usr/local/bin/libman

WORKDIR /src
COPY ["src/TrieuHiNeCon.Web.Mvc/TrieuHiNeCon.Web.Mvc.csproj", "src/TrieuHiNeCon.Web.Mvc/"]
COPY ["src/TrieuHiNeCon.Web.Core/TrieuHiNeCon.Web.Core.csproj", "src/TrieuHiNeCon.Web.Core/"]
COPY ["src/TrieuHiNeCon.Application/TrieuHiNeCon.Application.csproj", "src/TrieuHiNeCon.Application/"]
COPY ["src/TrieuHiNeCon.Core/TrieuHiNeCon.Core.csproj", "src/TrieuHiNeCon.Core/"]
COPY ["src/TrieuHiNeCon.EntityFrameworkCore/TrieuHiNeCon.EntityFrameworkCore.csproj", "src/TrieuHiNeCon.EntityFrameworkCore/"]
WORKDIR "/src/src/TrieuHiNeCon.Web.Mvc"
RUN dotnet restore 

WORKDIR /src
COPY ["src/TrieuHiNeCon.Web.Mvc", "src/TrieuHiNeCon.Web.Mvc"]
COPY ["src/TrieuHiNeCon.Web.Core", "src/TrieuHiNeCon.Web.Core"]
COPY ["src/TrieuHiNeCon.Application", "src/TrieuHiNeCon.Application"]
COPY ["src/TrieuHiNeCon.Core", "src/TrieuHiNeCon.Core"]
COPY ["src/TrieuHiNeCon.EntityFrameworkCore", "src/TrieuHiNeCon.EntityFrameworkCore"]
WORKDIR "/src/src/TrieuHiNeCon.Web.Mvc"
RUN libman restore
RUN dotnet publish -c Release -o /publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0
EXPOSE 80
WORKDIR /app
COPY --from=build /publish .
ENTRYPOINT ["dotnet", "TrieuHiNeCon.Web.Mvc.dll"]
