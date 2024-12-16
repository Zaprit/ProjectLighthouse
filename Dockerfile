# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /ProjectLighthouse
COPY *.sln ./
COPY **/*.csproj ./

RUN dotnet sln list | grep ".csproj" \
    | while read -r line; do \
    mkdir -p $(dirname $line); \
    mv $(basename $line) $(dirname $line); \
    done;

RUN dotnet restore

COPY . .
RUN dotnet publish -c Release --property:OutputPath=/ProjectLighthouse/out/ --no-restore

# Final running container
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS final

# Create lighthouse folders
RUN mkdir -p /lighthouse/data && \
mkdir -p /lighthouse/app && \
mkdir -p /lighthouse/temp && \
apk add --no-cache icu-libs su-exec tzdata

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Copy build files
COPY --from=build /ProjectLighthouse/out/publish /lighthouse/app
COPY --from=build /ProjectLighthouse/ProjectLighthouse/StaticFiles /lighthouse/temp/StaticFiles
COPY --from=build /ProjectLighthouse/scripts-and-tools/docker-entrypoint.sh /lighthouse

RUN chmod +x /lighthouse/docker-entrypoint.sh && \
cp /lighthouse/app/appsettings.json /lighthouse/temp

ENTRYPOINT ["/lighthouse/docker-entrypoint.sh"]
