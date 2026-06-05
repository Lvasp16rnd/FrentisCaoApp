drop function if exists public.like_post(uuid);

create or replace function public.like_post(p_post_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_current_likes uuid[];
  v_updated_likes uuid[];
  v_like_count integer;
begin
  if v_user_id is null then
    raise exception 'Usuario autenticado obrigatorio para curtir post.'
      using errcode = '28000';
  end if;

  select coalesce(likes_id, '{}'::uuid[])
    into v_current_likes
    from public.posts
    where id = p_post_id
    for update;

  if not found then
    raise exception 'Post nao encontrado.'
      using errcode = 'P0002';
  end if;

  if v_user_id = any(v_current_likes) then
    v_updated_likes := array_remove(v_current_likes, v_user_id);
  else
    v_updated_likes := array_append(v_current_likes, v_user_id);
  end if;

  v_like_count := cardinality(v_updated_likes);

  update public.posts
  set
    likes_id = v_updated_likes,
    like_count = v_like_count
  where id = p_post_id;

  return jsonb_build_object(
    'likes_id', v_updated_likes,
    'like_count', v_like_count
  );
end;
$$;

revoke all on function public.like_post(uuid) from public;
grant execute on function public.like_post(uuid) to authenticated;
