//! The database connection.

use toasty::Db;
use topcoat::context::{Cx, app_context};

/// Default local SQLite database file, created when it is first opened.
/// Override with the `DATABASE_URL` environment variable (the container does).
const DEFAULT_DATABASE_URL: &str = "sqlite:data.db";

/// Opens the database with every model in the application.
///
/// The tables come from migrations. After changing a model, generate a migration with
/// `cargo run -- toasty migration generate` and apply it with
/// `cargo run -- toasty migration apply`.
pub async fn connect() -> toasty::Result<Db> {
    let url = std::env::var("DATABASE_URL").unwrap_or_else(|_| DEFAULT_DATABASE_URL.to_owned());
    Db::builder()
        .models(toasty::models!(crate::*))
        .connect(&url)
        .await
}

/// Returns the database handle from the router's app context. Cloning it is cheap
/// because it refers to a shared connection pool.
pub fn db(cx: &Cx) -> Db {
    app_context::<Db>(cx).clone()
}
