-- MindStack: Kullanıcı ilerlemesini sıfırla (isteğe bağlı)
-- Supabase Dashboard → SQL Editor'de çalıştır.
--
-- Uyarı: Bu script seçilen kullanıcının quiz denemeleri, ders ilerlemesi ve istatistiklerini siler.
-- İçerik tablolarına (categories/tracks/lessons/questions/options) dokunmaz.
--
-- 1) Aşağıdaki UUID'yi hedef kullanıcı ile değiştir:
-- select id, email from auth.users order by created_at desc;

do $$
declare
  v_user uuid := '00000000-0000-0000-0000-000000000000';
begin
  if v_user = '00000000-0000-0000-0000-000000000000'::uuid then
    raise exception 'Lütfen v_user UUID değerini güncelle.';
  end if;

  delete from public.user_question_attempts where user_id = v_user;
  delete from public.user_lesson_progress where user_id = v_user;
  delete from public.user_track_stats where user_id = v_user;
  delete from public.user_stats where user_id = v_user;
end $$;

