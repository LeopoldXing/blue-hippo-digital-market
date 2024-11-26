Rails.application.config.session_store :redis_store, servers: {
  host: "localhost",
  port: 56784,
  db: 0,
  namespace: "bluehippo"
}, expires_in: 90.minutes
