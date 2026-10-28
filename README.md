# izylay

A [Topcoat](https://github.com/tokio-rs/topcoat) application.

## Development

### Install the Topcoat CLI

```
cargo install topcoat-cli
```

### Database migrations

Generate a migration from your models and apply it to the database:

```
cargo run -- toasty migration generate
cargo run -- toasty migration apply
```

Run these commands again after changing a model. Review generated migrations and commit them with your code.

During local development, the default database URL is `sqlite:data.db`, unless overridden by the `DATABASE_URL` environment variable.

### Start the development server

Start the development server, which rebuilds the application when you edit its source:

```
topcoat dev
```

Open [http://127.0.0.1:3000](http://127.0.0.1:3000).

## Project structure

| Path                                   | Contents                                                      |
| -------------------------------------- | ------------------------------------------------------------- |
| `src/app.rs`, `src/app/`               | The route tree: router, layouts, pages, and routes.           |
| `src/features.rs`, `src/features/`     | Feature-owned code, including data access and business rules. |
| `src/components.rs`, `src/components/` | Shared UI components that belong to no single feature.        |
| `src/db.rs`                            | Database connection configuration.                            |
| `toasty/`                              | Database migrations. Commit migrations with your code.        |

### Code organization

- Pages in `app` use features and shared components.
- Features can use shared components but must not import from `app`.
- Shared components must not import from individual features.

This keeps routing, feature logic, and reusable UI components separate.

## Docker

The Docker image builds the application and runs it as UID/GID `10001:10001`. The Compose configuration mounts the host's `./data` directory at `/app/data`, allowing the SQLite database to persist across container recreation.

### Build and start

From the project root:

```
mkdir -p data
sudo chown 10001:10001 data

docker compose up -d --build
```

To inspect the container:

```
docker compose ps
docker compose logs --tail=50 izylay
```

Open [http://127.0.0.1:3000](http://127.0.0.1:3000).

### Database persistence

In Docker, the database is stored at:

```
Host:      ./data/data.db
Container: /app/data/data.db
```

The Docker image configures:

```
DATABASE_URL=sqlite:/app/data/data.db
```

This overrides the local-development default, `sqlite:data.db`. Database migrations are applied automatically when the container starts.

**Important:** Keep `./data/data.db` when rebuilding or recreating the container. The database is stored on the host, outside the container's writable layer.

### Stop the application

```
docker compose stop
```

To start it again:

```
docker compose start
```

To rebuild after changing application code or the Docker image:

```
docker compose up -d --build
```

Do not use `docker compose down -v` unless you intend to remove associated Compose-managed volumes. The SQLite database in `./data` is a bind-mounted host file and should be preserved separately.

## License

This project is licensed under the [MIT License](LICENSE).

## Learn more

- [Topcoat getting started guide](https://github.com/tokio-rs/topcoat/blob/main/docs/getting_started.md)
- [Topcoat guides](https://github.com/tokio-rs/topcoat/tree/main#learn-topcoat)
- [Topcoat repository](https://github.com/tokio-rs/topcoat)
