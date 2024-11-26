# config/initializers/session_store.rb

Rails.application.config.session_store :redis_store,
                                       servers: [
                                         {
                                           host: "localhost",
                                           port: 56784,
                                           db: 0,
                                           namespace: "bluehippo"
                                         }
                                       ],
                                       expire_after: 90.minutes,
                                       key: "bluehippo"
