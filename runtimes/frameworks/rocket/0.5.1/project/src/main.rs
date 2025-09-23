#[macro_use] extern crate rocket;

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .configure(rocket::Config::figment()
            .merge(("address", "0.0.0.0")))
        .mount("/", routes![index])
}
