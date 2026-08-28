# Dockerfile para API Dart (template)

# Stage 1: Build
FROM dart:stable AS build

WORKDIR /app

# Copia arquivos de dependências primeiro (cache de layers)
COPY pubspec.* ./
RUN dart pub get

# Copia o restante do código
COPY . .

# Compila para executável nativo
RUN dart compile exe bin/main.dart -o bin/server

# Stage 2: Runtime (imagem minima)
FROM debian:bookworm-slim

# Instala certificados SSL (necessario para conexoes HTTPS)
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia apenas o executável compilado
COPY --from=build /app/bin/server /app/bin/server

# Expõe a porta da API
EXPOSE 8080

# Comando para iniciar o servidor
CMD ["/app/bin/server"]
