-- Hotfix: record_question_attempt - "total_xp is ambiguous" düzeltmesi
-- Supabase SQL Editor'de çalıştır.

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

  select (s.last_active_at at time zone 'utc')::date
    into v_last
  from public.user_stats s
  where s.user_id = v_user_id;

  update public.user_stats s
  set
    total_xp = s.total_xp + (case when p_is_correct then v_xp else 0 end),
    current_streak = case
      when v_last is null then 1
      when v_last = v_today then s.current_streak
      when v_last = (v_today - 1) then s.current_streak + 1
      else 1
    end,
    best_streak = greatest(
      s.best_streak,
      case
        when v_last is null then 1
        when v_last = v_today then s.current_streak
        when v_last = (v_today - 1) then s.current_streak + 1
        else 1
      end
    ),
    last_active_at = now()
  where s.user_id = v_user_id;

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

