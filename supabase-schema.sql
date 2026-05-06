-- Tabela de tarefas
create table if not exists tasks (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid not null references auth.users(id),
  title text not null,
  description text,
  category text,
  due_date timestamp with time zone,
  completed boolean not null default false,
  is_pinned boolean not null default false,
  created_at timestamp with time zone not null default now()
);

-- Se a tabela já existir, adiciona as colunas se ainda não existirem
alter table tasks add column if not exists due_date timestamp with time zone;
alter table tasks add column if not exists is_pinned boolean not null default false;
alter table tasks add column if not exists repeat_type text not null default 'none';
alter table tasks add column if not exists repeat_interval int not null default 1;

-- Tabela de metas (opcional)
create table if not exists goals (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid not null references auth.users(id),
  title text not null,
  progress int not null default 0,
  created_at timestamp with time zone not null default now()
);
