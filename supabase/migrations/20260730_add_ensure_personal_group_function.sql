-- 개인 그룹 자동 생성(groups insert → group_members insert)을 앱에서 두 번의
-- 별도 쿼리로 처리하면, groups insert 직후 `.select()`로 되읽는 순간
-- group_members에 아직 본인 행이 없어 `groups`의 SELECT 정책
-- (is_group_member(id, auth.uid()))이 막아서 RETURNING이 0건으로 걸러진다.
--
-- SECURITY DEFINER 함수 안에서 두 insert를 함께 처리하면 함수 내부 쿼리는
-- RLS를 우회하므로 이 타이밍 문제가 사라진다.
create or replace function public.ensure_personal_group(p_user_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_group_id uuid;
begin
  select g.id into v_group_id
  from public.groups g
  join public.group_members gm on gm.group_id = g.id
  where gm.user_id = p_user_id
  limit 1;

  if v_group_id is not null then
    return v_group_id;
  end if;

  insert into public.groups (name, created_by)
  values ('개인 기록', p_user_id)
  returning id into v_group_id;

  insert into public.group_members (group_id, user_id)
  values (v_group_id, p_user_id);

  return v_group_id;
end;
$$;

grant execute on function public.ensure_personal_group(uuid) to authenticated;
