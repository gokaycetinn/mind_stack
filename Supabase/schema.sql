-- MindStack (Swift) - Supabase schema (TR)
-- Çalıştırma: Supabase SQL Editor'de tek seferde çalıştırın.
-- Not: Bu şema Auth (email/password) kullanan bir eğitim uygulaması için tasarlanmıştır.

begin;

-- Extensions
create extension if not exists pgcrypto;

-- Content: categories -> tracks -> lessons -> questions -> options
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  sort int not null default 0,
  created_at timestamptz not null default now()
);
create unique index if not exists categories_title_ux on public.categories (title);

create table if not exists public.tracks (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references public.categories(id) on delete cascade,
  title text not null,
  description text,
  level text,
  sort int not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists tracks_category_id_idx on public.tracks(category_id);
create unique index if not exists tracks_category_title_ux on public.tracks (category_id, title);

create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  track_id uuid not null references public.tracks(id) on delete cascade,
  title text not null,
  content_md text not null,
  est_minutes int not null default 5,
  sort int not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists lessons_track_id_idx on public.lessons(track_id);
create unique index if not exists lessons_track_title_ux on public.lessons (track_id, title);

do $$ begin
  if not exists (select 1 from pg_type where typname = 'question_type') then
    create type public.question_type as enum ('single_choice','multi_choice','true_false');
  end if;
end $$;

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  type public.question_type not null default 'single_choice',
  prompt text not null,
  explanation text,
  difficulty int not null default 1,
  xp_reward int not null default 10,
  sort int not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists questions_lesson_id_idx on public.questions(lesson_id);
create unique index if not exists questions_lesson_sort_ux on public.questions (lesson_id, sort);

create table if not exists public.question_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions(id) on delete cascade,
  text text not null,
  is_correct boolean not null default false,
  sort int not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists question_options_question_id_idx on public.question_options(question_id);
create unique index if not exists question_options_question_sort_ux on public.question_options (question_id, sort);

-- User state / analytics
create table if not exists public.user_stats (
  user_id uuid primary key references auth.users(id) on delete cascade,
  total_xp int not null default 0,
  current_streak int not null default 0,
  best_streak int not null default 0,
  last_active_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_lesson_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  status text not null default 'not_started', -- not_started|in_progress|completed
  progress_pct int not null default 0,
  last_seen_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (user_id, lesson_id)
);

create table if not exists public.user_question_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete cascade,
  is_correct boolean not null,
  chosen_option_ids uuid[] not null default '{}'::uuid[],
  duration_ms int,
  answered_at timestamptz not null default now()
);
create index if not exists user_question_attempts_user_id_idx on public.user_question_attempts(user_id);
create index if not exists user_question_attempts_question_id_idx on public.user_question_attempts(question_id);

create table if not exists public.user_track_stats (
  user_id uuid not null references auth.users(id) on delete cascade,
  track_id uuid not null references public.tracks(id) on delete cascade,
  correct_count int not null default 0,
  wrong_count int not null default 0,
  last_practiced_at timestamptz,
  primary key (user_id, track_id)
);
create index if not exists user_track_stats_user_id_idx on public.user_track_stats(user_id);

-- updated_at trigger helper
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists user_stats_touch on public.user_stats;
create trigger user_stats_touch
before update on public.user_stats
for each row execute function public.touch_updated_at();

-- RPC: record attempt (atomic insert + stats update)
create or replace function public.record_question_attempt(
  p_question_id uuid,
  p_is_correct boolean,
  p_chosen_option_ids uuid[] default '{}'::uuid[],
  p_duration_ms int default null
)
returns table (
  total_xp int,
  current_streak int,
  best_streak int
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_today date := (now() at time zone 'utc')::date;
  v_last date;
  v_xp int := 0;
  v_track_id uuid;
begin
  if v_user_id is null then
    raise exception 'not_authenticated';
  end if;

  select q.xp_reward, l.track_id
    into v_xp, v_track_id
  from public.questions q
  join public.lessons l on l.id = q.lesson_id
  where q.id = p_question_id;

  insert into public.user_question_attempts(user_id, question_id, is_correct, chosen_option_ids, duration_ms)
  values (v_user_id, p_question_id, p_is_correct, coalesce(p_chosen_option_ids, '{}'::uuid[]), p_duration_ms);

  insert into public.user_stats(user_id, total_xp, current_streak, best_streak, last_active_at)
  values (v_user_id, 0, 0, 0, now())
  on conflict (user_id) do nothing;

  select (user_stats.last_active_at at time zone 'utc')::date
    into v_last
  from public.user_stats
  where user_id = v_user_id;

  -- Not: OUT param isimleri (total_xp gibi) PL/pgSQL scope'unda değişken sayılır.
  -- Kolon isimleriyle çakışmayı önlemek için tablo alias'ı kullanıyoruz.
  update public.user_stats s
  set
    total_xp = s.total_xp + (case when p_is_correct then v_xp else 0 end),
    current_streak = case
      when v_last is null then 1
      when v_last = v_today then current_streak
      when v_last = (v_today - 1) then current_streak + 1
      else 1
    end,
    best_streak = greatest(
      best_streak,
      case
        when v_last is null then 1
        when v_last = v_today then current_streak
        when v_last = (v_today - 1) then current_streak + 1
        else 1
      end
    ),
    last_active_at = now()
  where s.user_id = v_user_id;

  -- per-track aggregation
  if v_track_id is not null then
    insert into public.user_track_stats(user_id, track_id, correct_count, wrong_count, last_practiced_at)
    values (
      v_user_id,
      v_track_id,
      case when p_is_correct then 1 else 0 end,
      case when p_is_correct then 0 else 1 end,
      now()
    )
    on conflict (user_id, track_id) do update set
      correct_count = user_track_stats.correct_count + (case when p_is_correct then 1 else 0 end),
      wrong_count = user_track_stats.wrong_count + (case when p_is_correct then 0 else 1 end),
      last_practiced_at = now();
  end if;

  return query
  select s.total_xp, s.current_streak, s.best_streak
  from public.user_stats s
  where s.user_id = v_user_id;
end;
$$;

grant execute on function public.record_question_attempt(uuid, boolean, uuid[], int) to authenticated;

-- RPC: günlük XP özeti (grafik için)
create or replace function public.get_user_daily_xp(p_days int default 14)
returns table (
  day date,
  xp int,
  correct int,
  wrong int
)
language sql
security definer
set search_path = public
as $$
  with params as (
    select
      (now() at time zone 'utc')::date as today,
      greatest(1, p_days) as days
  ),
  attempts as (
    select
      (a.answered_at at time zone 'utc')::date as day,
      sum(case when a.is_correct then q.xp_reward else 0 end)::int as xp,
      sum(case when a.is_correct then 1 else 0 end)::int as correct,
      sum(case when a.is_correct then 0 else 1 end)::int as wrong
    from public.user_question_attempts a
    join public.questions q on q.id = a.question_id
    where a.user_id = auth.uid()
      and a.answered_at >= (now() at time zone 'utc') - make_interval(days => (select days from params))
    group by (a.answered_at at time zone 'utc')::date
  )
  select
    (w.today - (g.i * interval '1 day'))::date as day,
    coalesce(attempts.xp, 0) as xp,
    coalesce(attempts.correct, 0) as correct,
    coalesce(attempts.wrong, 0) as wrong
  from params w
  cross join generate_series(0, (select days - 1 from params)) as g(i)
  left join attempts on attempts.day = (w.today - (g.i * interval '1 day'))::date
  order by day asc;
$$;

grant execute on function public.get_user_daily_xp(int) to authenticated;

-- RPC: kullanıcı özeti (profil/istatistik)
create or replace function public.get_user_summary()
returns table (
  total_xp int,
  current_streak int,
  best_streak int,
  correct int,
  wrong int
)
language sql
security definer
set search_path = public
as $$
  with stats as (
    select
      coalesce(s.total_xp, 0)::int as total_xp,
      coalesce(s.current_streak, 0)::int as current_streak,
      coalesce(s.best_streak, 0)::int as best_streak
    from public.user_stats s
    where s.user_id = auth.uid()
  ),
  attempts as (
    select
      sum(case when a.is_correct then 1 else 0 end)::int as correct,
      sum(case when a.is_correct then 0 else 1 end)::int as wrong
    from public.user_question_attempts a
    where a.user_id = auth.uid()
  )
  select
    coalesce(stats.total_xp, 0) as total_xp,
    coalesce(stats.current_streak, 0) as current_streak,
    coalesce(stats.best_streak, 0) as best_streak,
    coalesce(attempts.correct, 0) as correct,
    coalesce(attempts.wrong, 0) as wrong
  from stats
  cross join attempts;
$$;

grant execute on function public.get_user_summary() to authenticated;

-- RPC: konu bazlı doğru/yanlış (Analytics)
create or replace function public.get_user_track_breakdown(p_limit int default 6)
returns table (
  track_id uuid,
  track_title text,
  category_title text,
  correct_count int,
  wrong_count int,
  accuracy double precision
)
language sql
security definer
set search_path = public
as $$
  select
    t.id as track_id,
    t.title as track_title,
    c.title as category_title,
    coalesce(uts.correct_count, 0)::int as correct_count,
    coalesce(uts.wrong_count, 0)::int as wrong_count,
    case
      when coalesce(uts.correct_count, 0) + coalesce(uts.wrong_count, 0) = 0 then 0
      else (coalesce(uts.correct_count, 0)::double precision / (coalesce(uts.correct_count, 0) + coalesce(uts.wrong_count, 0))::double precision)
    end as accuracy
  from public.user_track_stats uts
  join public.tracks t on t.id = uts.track_id
  join public.categories c on c.id = t.category_id
  where uts.user_id = auth.uid()
  order by (uts.correct_count + uts.wrong_count) desc, uts.last_practiced_at desc nulls last
  limit greatest(1, least(20, coalesce(p_limit, 6)));
$$;

grant execute on function public.get_user_track_breakdown(int) to authenticated;

-- RLS
alter table public.categories enable row level security;
alter table public.tracks enable row level security;
alter table public.lessons enable row level security;
alter table public.questions enable row level security;
alter table public.question_options enable row level security;
alter table public.user_stats enable row level security;
alter table public.user_lesson_progress enable row level security;
alter table public.user_question_attempts enable row level security;
alter table public.user_track_stats enable row level security;

-- Content read policies (authenticated users)
drop policy if exists "categories_read" on public.categories;
create policy "categories_read" on public.categories
for select to authenticated
using (true);

drop policy if exists "tracks_read" on public.tracks;
create policy "tracks_read" on public.tracks
for select to authenticated
using (true);

drop policy if exists "lessons_read" on public.lessons;
create policy "lessons_read" on public.lessons
for select to authenticated
using (true);

drop policy if exists "questions_read" on public.questions;
create policy "questions_read" on public.questions
for select to authenticated
using (true);

drop policy if exists "question_options_read" on public.question_options;
create policy "question_options_read" on public.question_options
for select to authenticated
using (true);

-- User tables: self-only
drop policy if exists "user_stats_self" on public.user_stats;
create policy "user_stats_self" on public.user_stats
for all to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "user_lesson_progress_self" on public.user_lesson_progress;
create policy "user_lesson_progress_self" on public.user_lesson_progress
for all to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "user_question_attempts_self" on public.user_question_attempts;
create policy "user_question_attempts_self" on public.user_question_attempts
for all to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "user_track_stats_self" on public.user_track_stats;
create policy "user_track_stats_self" on public.user_track_stats
for all to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Seed (minimal TR)
insert into public.categories (title, description, sort)
values
  ('Algoritmalar', 'Temel algoritma ve veri yapıları', 1),
  ('Sistem Tasarımı', 'Ölçeklenebilir sistemler ve mimari', 2)
on conflict (title) do update set
  description = excluded.description,
  sort = excluded.sort;

-- Tracks (örnek)
with c as (select id from public.categories where title = 'Algoritmalar')
insert into public.tracks (category_id, title, description, level, sort)
select c.id, 'Algoritmalara Giriş', 'Sıralama, arama ve temel analiz', 'Başlangıç', 1
from c
on conflict (category_id, title) do update set
  description = excluded.description,
  level = excluded.level,
  sort = excluded.sort;

with c as (select id from public.categories where title = 'Sistem Tasarımı')
insert into public.tracks (category_id, title, description, level, sort)
select c.id, 'API Tasarımı', 'Rate limiting, caching, pagination', 'Başlangıç', 1
from c
on conflict (category_id, title) do update set
  description = excluded.description,
  level = excluded.level,
  sort = excluded.sort;

-- Lessons (örnek)
with t as (select id from public.tracks where title = 'Algoritmalara Giriş' limit 1)
insert into public.lessons (track_id, title, content_md, est_minutes, sort)
select
  t.id,
  'Big‑O Temelleri',
  '# Big‑O Temelleri\n\nBig‑O, algoritmanın girdi büyüdükçe nasıl ölçeklendiğini anlatır.\n\n- O(1): sabit\n- O(log n): logaritmik\n- O(n): doğrusal\n- O(n log n): verimli sıralamalar\n- O(n^2): iki döngü\n\nAmaç: maliyeti anlamak ve doğru yapıyı seçmek.',
  6,
  1
from t
on conflict (track_id, title) do update set
  content_md = excluded.content_md,
  est_minutes = excluded.est_minutes,
  sort = excluded.sort;

with t as (select id from public.tracks where title = 'API Tasarımı' limit 1)
insert into public.lessons (track_id, title, content_md, est_minutes, sort)
select
  t.id,
  'Rate Limiting Nedir?',
  '# Rate Limiting\n\nRate limiting, istemcilerin belirli bir zaman aralığında yapabileceği istek sayısını sınırlar.\n\nNeden gerekli?\n- Abuse / DDOS azaltma\n- Adil kullanım\n- Servisleri koruma\n\nYaygın stratejiler:\n- Fixed Window\n- Sliding Window\n- Token Bucket\n- Leaky Bucket',
  7,
  1
from t
on conflict (track_id, title) do update set
  content_md = excluded.content_md,
  est_minutes = excluded.est_minutes,
  sort = excluded.sort;

-- Questions (örnek)
with l as (select id from public.lessons where title = 'Big‑O Temelleri' limit 1)
insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
select
  l.id,
  'single_choice',
  'Aşağıdakilerden hangisi genellikle en hızlı büyüyen karmaşıklıktır?',
  'n büyüdükçe n^2, n ve log n gibi terimlerden daha hızlı büyür.',
  1,
  10,
  1
from l
on conflict (lesson_id, sort) do update set
  prompt = excluded.prompt,
  explanation = excluded.explanation,
  difficulty = excluded.difficulty,
  xp_reward = excluded.xp_reward;

with q as (
  select id from public.questions
  where prompt = 'Aşağıdakilerden hangisi genellikle en hızlı büyüyen karmaşıklıktır?'
  limit 1
)
insert into public.question_options (question_id, text, is_correct, sort)
select q.id, v.text, v.is_correct, v.sort
from q
cross join (values
  ('O(1)', false, 1),
  ('O(log n)', false, 2),
  ('O(n)', false, 3),
  ('O(n^2)', true, 4)
) as v(text, is_correct, sort)
on conflict (question_id, sort) do update set
  text = excluded.text,
  is_correct = excluded.is_correct;

with l as (select id from public.lessons where title = 'Rate Limiting Nedir?' limit 1)
insert into public.questions (lesson_id, type, prompt, explanation, difficulty, xp_reward, sort)
select
  l.id,
  'single_choice',
  'Rate limiting’in temel amacı nedir?',
  'Amaç, kaynakları korumak ve adil kullanım sağlamak için istekleri sınırlamaktır.',
  1,
  10,
  1
from l
on conflict (lesson_id, sort) do update set
  prompt = excluded.prompt,
  explanation = excluded.explanation,
  difficulty = excluded.difficulty,
  xp_reward = excluded.xp_reward;

with q as (
  select id from public.questions
  where prompt = 'Rate limiting’in temel amacı nedir?'
  limit 1
)
insert into public.question_options (question_id, text, is_correct, sort)
select q.id, v.text, v.is_correct, v.sort
from q
cross join (values
  ('Daha fazla log üretmek', false, 1),
  ('İstekleri sınırlayarak servisleri korumak', true, 2),
  ('Veritabanını tamamen kapatmak', false, 3)
) as v(text, is_correct, sort)
on conflict (question_id, sort) do update set
  text = excluded.text,
  is_correct = excluded.is_correct;

commit;
