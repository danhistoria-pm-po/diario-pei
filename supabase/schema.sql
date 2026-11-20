-- ============================================================================
-- Diário PEI - Schema PostgreSQL / Supabase
-- Tabelas: alunos, metas_pei, registros_diario
-- Segurança: Row Level Security (RLS) por professor autenticado (auth.uid())
-- ============================================================================

create extension if not exists "pgcrypto";

-- ----------------------------------------------------------------------------
-- 1. Tabela de Alunos
-- ----------------------------------------------------------------------------
create table if not exists public.alunos (
  id uuid primary key default gen_random_uuid(),
  professor_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  nome text not null,
  turma text not null,
  diagnostico text,
  observacoes text,
  criado_em timestamptz not null default now()
);

create index if not exists idx_alunos_professor_id on public.alunos (professor_id);
create index if not exists idx_alunos_nome on public.alunos (nome);

-- ----------------------------------------------------------------------------
-- 2. Tabela de Metas do PEI
-- ----------------------------------------------------------------------------
create table if not exists public.metas_pei (
  id uuid primary key default gen_random_uuid(),
  aluno_id uuid not null references public.alunos(id) on delete cascade,
  professor_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  area text not null,
  titulo text not null,
  descricao text,
  status text not null default 'pendente'
    check (status in ('pendente', 'em_andamento', 'atingida')),
  prazo date,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index if not exists idx_metas_pei_aluno_id on public.metas_pei (aluno_id);
create index if not exists idx_metas_pei_professor_id on public.metas_pei (professor_id);

-- ----------------------------------------------------------------------------
-- 3. Tabela de Registros do Diário de Bordo
-- ----------------------------------------------------------------------------
create table if not exists public.registros_diario (
  id uuid primary key default gen_random_uuid(),
  aluno_id uuid not null references public.alunos(id) on delete cascade,
  professor_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  data_registro date not null default current_date,
  categoria text not null default 'Acompanhamento',
  descricao text not null,
  criado_em timestamptz not null default now()
);

create index if not exists idx_registros_diario_aluno_id
  on public.registros_diario (aluno_id, data_registro desc, criado_em desc);
create index if not exists idx_registros_diario_professor_id
  on public.registros_diario (professor_id);

-- ----------------------------------------------------------------------------
-- Trigger para manter atualizado_em em metas_pei
-- ----------------------------------------------------------------------------
create or replace function public.set_atualizado_em()
returns trigger
language plpgsql
as $$
begin
  new.atualizado_em = now();
  return new;
end;
$$;

drop trigger if exists trg_metas_pei_atualizado_em on public.metas_pei;
create trigger trg_metas_pei_atualizado_em
before update on public.metas_pei
for each row
execute function public.set_atualizado_em();

-- ----------------------------------------------------------------------------
-- Row Level Security (RLS)
-- ----------------------------------------------------------------------------
alter table public.alunos enable row level security;
alter table public.metas_pei enable row level security;
alter table public.registros_diario enable row level security;

-- Políticas: alunos
drop policy if exists "Professores veem seus proprios alunos" on public.alunos;
create policy "Professores veem seus proprios alunos"
  on public.alunos for select
  using (auth.uid() = professor_id);

drop policy if exists "Professores criam seus proprios alunos" on public.alunos;
create policy "Professores criam seus proprios alunos"
  on public.alunos for insert
  with check (auth.uid() = professor_id);

drop policy if exists "Professores atualizam seus proprios alunos" on public.alunos;
create policy "Professores atualizam seus proprios alunos"
  on public.alunos for update
  using (auth.uid() = professor_id)
  with check (auth.uid() = professor_id);

drop policy if exists "Professores excluem seus proprios alunos" on public.alunos;
create policy "Professores excluem seus proprios alunos"
  on public.alunos for delete
  using (auth.uid() = professor_id);

-- Políticas: metas_pei
drop policy if exists "Professores veem metas dos seus alunos" on public.metas_pei;
create policy "Professores veem metas dos seus alunos"
  on public.metas_pei for select
  using (auth.uid() = professor_id);

drop policy if exists "Professores criam metas para seus alunos" on public.metas_pei;
create policy "Professores criam metas para seus alunos"
  on public.metas_pei for insert
  with check (
    auth.uid() = professor_id
    and exists (
      select 1 from public.alunos a
      where a.id = aluno_id and a.professor_id = auth.uid()
    )
  );

drop policy if exists "Professores atualizam metas dos seus alunos" on public.metas_pei;
create policy "Professores atualizam metas dos seus alunos"
  on public.metas_pei for update
  using (auth.uid() = professor_id)
  with check (auth.uid() = professor_id);

drop policy if exists "Professores excluem metas dos seus alunos" on public.metas_pei;
create policy "Professores excluem metas dos seus alunos"
  on public.metas_pei for delete
  using (auth.uid() = professor_id);

-- Políticas: registros_diario
drop policy if exists "Professores veem registros dos seus alunos" on public.registros_diario;
create policy "Professores veem registros dos seus alunos"
  on public.registros_diario for select
  using (auth.uid() = professor_id);

drop policy if exists "Professores criam registros para seus alunos" on public.registros_diario;
create policy "Professores criam registros para seus alunos"
  on public.registros_diario for insert
  with check (
    auth.uid() = professor_id
    and exists (
      select 1 from public.alunos a
      where a.id = aluno_id and a.professor_id = auth.uid()
    )
  );

drop policy if exists "Professores atualizam registros dos seus alunos" on public.registros_diario;
create policy "Professores atualizam registros dos seus alunos"
  on public.registros_diario for update
  using (auth.uid() = professor_id)
  with check (auth.uid() = professor_id);

drop policy if exists "Professores excluem registros dos seus alunos" on public.registros_diario;
create policy "Professores excluem registros dos seus alunos"
  on public.registros_diario for delete
  using (auth.uid() = professor_id);
