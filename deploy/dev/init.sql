CREATE TABLE public.users
(
    id             bigserial          NOT NULL,
    payload_id     varchar NULL,
    username       varchar NULL,
    email          varchar NULL,
    province       varchar NULL,
    address_line_1 varchar NULL,
    address_line_2 varchar NULL,
    postal_code    varchar NULL,
    password_hash  varchar NULL,
    salt           varchar NULL,
    "role"         varchar NULL,
    verified       bool DEFAULT false NOT NULL,
    "locked"       bool DEFAULT false NOT NULL,
    lock_until     timestamp NULL,
    created_at     timestamp          NOT NULL,
    created_by     varchar            NOT NULL,
    updated_at     timestamp          NOT NULL,
    updated_by     varchar            NOT NULL,
    CONSTRAINT users_pk PRIMARY KEY (id)
);

CREATE TABLE public.products
(
    id                bigserial                   NOT NULL,
    user_id           bigserial                   NOT NULL,
    payload_id        varchar                     NOT NULL,
    "name"            varchar                     NOT NULL,
    description       text NULL,
    price             numeric(10, 2) DEFAULT 0.00 NOT NULL,
    price_id          varchar NULL,
    stripe_id         varchar NULL,
    category          varchar NULL,
    product_file_url  varchar                     NOT NULL,
    approved_for_sale varchar        DEFAULT 'pending'::character varying NOT NULL,
    created_at        timestamp                   NOT NULL,
    created_by        varchar                     NOT NULL,
    updated_at        timestamp                   NOT NULL,
    updated_by        varchar                     NOT NULL,
    CONSTRAINT products_pk PRIMARY KEY (id),
    CONSTRAINT products_users_fk FOREIGN KEY (user_id) REFERENCES public.users (id)
);


CREATE TABLE public.product_images
(
    id         bigserial NOT NULL,
    product_id bigserial NOT NULL,
    payload_id varchar   NOT NULL,
    url        varchar   NOT NULL,
    filename   varchar NULL,
    filesize   numeric(10, 1) NULL,
    height     numeric NULL,
    width      numeric NULL,
    mime_type  varchar NULL,
    file_type  varchar NULL,
    created_at timestamp NOT NULL,
    created_by varchar   NOT NULL,
    updated_at timestamp NOT NULL,
    updated_by varchar   NOT NULL,
    CONSTRAINT product_images_pk PRIMARY KEY (id),
    CONSTRAINT product_images_products_fk FOREIGN KEY (product_id) REFERENCES public.products (id)
);


CREATE TABLE public.orders
(
    id         bigserial NOT NULL,
    payload_id varchar NULL,
    user_id    bigserial NOT NULL,
    is_paid    bool DEFAULT false NULL,
    tax_type   varchar NULL,
    gst        numeric(5, 2) NULL,
    pst        numeric(5, 2) NULL,
    hst        numeric(5, 2) NULL,
    created_at timestamp NULL,
    created_by varchar NULL,
    updated_at timestamp NULL,
    updated_by varchar NULL,
    CONSTRAINT orders_pk PRIMARY KEY (id),
    CONSTRAINT orders_users_fk FOREIGN KEY (user_id) REFERENCES public.users (id)
);


CREATE TABLE public.link_orders_products
(
    id         bigserial NOT NULL,
    product_id bigserial NOT NULL,
    order_id   bigserial NOT NULL,
    created_at timestamp NULL,
    created_by varchar NULL,
    updated_at timestamp NULL,
    updated_by varchar NULL,
    CONSTRAINT link_orders_products_pk PRIMARY KEY (id),
    CONSTRAINT link_orders_products_orders_fk FOREIGN KEY (order_id) REFERENCES public.orders (id),
    CONSTRAINT link_orders_products_products_fk FOREIGN KEY (product_id) REFERENCES public.products (id)
);


CREATE TABLE public.carts
(
    id         bigserial NOT NULL,
    product_id bigserial NOT NULL,
    user_id    bigserial NOT NULL,
    created_at timestamp NOT NULL,
    created_by varchar   NOT NULL,
    updated_at timestamp NOT NULL,
    updated_by varchar   NOT NULL,
    CONSTRAINT carts_pk PRIMARY KEY (id),
    CONSTRAINT carts_products_fk FOREIGN KEY (product_id) REFERENCES public.products (id),
    CONSTRAINT carts_users_fk FOREIGN KEY (user_id) REFERENCES public.users (id)
);


-- taxes
CREATE TABLE canada_sales_tax
(
    id            SERIAL PRIMARY KEY,
    province_name VARCHAR(50) NOT NULL,        -- Province name
    province_code CHAR(2)     NOT NULL UNIQUE, -- Province code (e.g., ON, BC)
    gst_rate      DECIMAL(5, 2) DEFAULT 0.00,  -- GST rate (percentage format)
    pst_rate      DECIMAL(5, 2) DEFAULT 0.00,  -- PST rate (percentage format)
    hst_rate      DECIMAL(5, 2) DEFAULT 0.00,  -- HST rate (percentage format)
    tax_type      VARCHAR(10) NOT NULL         -- Tax type (e.g., "GST+PST", "HST")
);

INSERT INTO canada_sales_tax (province_name, province_code, gst_rate, pst_rate, hst_rate, tax_type)
VALUES ('Alberta', 'AB', 5.00, 0.00, 0.00, 'GST'),                    -- GST only
       ('British Columbia', 'BC', 5.00, 7.00, 0.00, 'GST+PST'),       -- GST + PST
       ('Manitoba', 'MB', 5.00, 7.00, 0.00, 'GST+PST'),               -- GST + PST
       ('New Brunswick', 'NB', 0.00, 0.00, 15.00, 'HST'),             -- HST
       ('Newfoundland and Labrador', 'NL', 0.00, 0.00, 15.00, 'HST'), -- HST
       ('Northwest Territories', 'NT', 5.00, 0.00, 0.00, 'GST'),      -- GST only
       ('Nova Scotia', 'NS', 0.00, 0.00, 15.00, 'HST'),               -- HST
       ('Nunavut', 'NU', 5.00, 0.00, 0.00, 'GST'),                    -- GST only
       ('Ontario', 'ON', 0.00, 0.00, 13.00, 'HST'),                   -- HST
       ('Prince Edward Island', 'PE', 0.00, 0.00, 15.00, 'HST'),      -- HST
       ('Quebec', 'QC', 5.00, 9.975, 0.00, 'GST+PST'),                -- GST + PST
       ('Saskatchewan', 'SK', 5.00, 6.00, 0.00, 'GST+PST'),           -- GST + PST
       ('Yukon', 'YT', 5.00, 0.00, 0.00, 'GST'); -- GST only


