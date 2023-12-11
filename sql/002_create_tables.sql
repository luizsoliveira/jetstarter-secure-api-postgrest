CREATE schema secure;

CREATE TABLE "secure"."users" (
  "id" serial PRIMARY KEY,
  "first_name" varchar NOT NULL,
  "last_name" varchar NOT NULL,
  "email" text UNIQUE check ( email ~* '^.+@.+\..+$' ),
  "pass" text not null check (length(pass) < 512),
  "role" name not null check (length(role) < 512),
  "created_at" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE "secure"."projects" (
  "id" serial PRIMARY KEY,
  "title" varchar NOT NULL,
  "description" text,
  "manager_user_id" integer NOT NULL,
  "created_at" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE "secure"."project_members" (
  "id" serial PRIMARY KEY,
  "user_id" integer NOT NULL,
  "project_id" integer NOT NULL,
  "created_at" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE "secure"."tasks" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "project_id" integer NOT NULL,
  "title" varchar NOT NULL,
  "description" text,
  "task_type_id" integer,
  "parameters" json,
  "output" json,
  "return_code" integer,
  "created_at" TIMESTAMP DEFAULT NOW(),
  "started_at" timestamp,
  "finished_at" timestamp
);

CREATE TABLE "secure"."task_types" (
  "id" serial PRIMARY KEY,
  "title" varchar NOT NULL,
  "slug" varchar NOT NULL,
  "created_at" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS secure.task_types
(
    id integer NOT NULL DEFAULT nextval('task_types_id_seq'::regclass),
    title character varying COLLATE pg_catalog."default",
    created_at timestamp without time zone DEFAULT now(),
    slug text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT task_types_pkey PRIMARY KEY (id)
);


COMMENT ON COLUMN "secure"."projects"."description" IS 'Description of the project';

COMMENT ON COLUMN "secure"."tasks"."description" IS 'Description of the task';

ALTER TABLE "secure"."project_members" ADD CONSTRAINT project_members_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES secure.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE;

ALTER TABLE "secure"."project_members" ADD CONSTRAINT project_members_project_id_fkey FOREIGN KEY (project_id)
        REFERENCES secure.projects (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE;

ALTER TABLE "secure"."projects" ADD CONSTRAINT projects_manager_user_id_fkey FOREIGN KEY (manager_user_id)
        REFERENCES secure.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL;

ALTER TABLE "secure"."tasks" ADD CONSTRAINT tasks_project_id_fkey FOREIGN KEY (project_id)
        REFERENCES secure.projects (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE;

ALTER TABLE "secure"."tasks" ADD FOREIGN KEY ("task_type_id") REFERENCES "secure"."task_types" ("id");

ALTER TABLE "secure"."project_members" ADD CONSTRAINT project_members_user_project_unique UNIQUE (user_id, project_id);


-- Giving access only for the authenticated users
GRANT ALL ON TABLE secure.users TO app_user;
GRANT ALL ON TABLE secure.projects TO app_user;
GRANT ALL ON TABLE secure.project_members TO app_user;
GRANT ALL ON TABLE secure.tasks TO app_user;
GRANT ALL ON TABLE secure.task_types TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA secure TO app_user;