-- =========================================================================
-- RBAC (Role-Based Access Control) — Texnoptom ERP
-- Bu faylni Supabase SQL Editor'da bir marta ishga tushiring.
-- Asosiy biznes jadvallar yaratilgandan KEYIN qo'llang.
-- =========================================================================

-- ---------- 1. PROFILES jadvali ----------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  role text not null default 'skladchi'
    check (role in ('admin', 'skladchi')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Foydalanuvchi o'z profilini ko'ra oladi
drop policy if exists "read_own_profile" on public.profiles;
create policy "read_own_profile" on public.profiles
  for select using (auth.uid() = id);

-- Admin barcha profillarni ko'ra oladi
drop policy if exists "admin_read_all_profiles" on public.profiles;
create policy "admin_read_all_profiles" on public.profiles
  for select using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Faqat admin role'larni o'zgartira oladi
drop policy if exists "admin_manage_profiles" on public.profiles;
create policy "admin_manage_profiles" on public.profiles
  for all using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- ---------- 2. Yordamchi funksiya: is_admin() ----------
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- ---------- 3. Yangi user yaratilganda profil avtomat yaratish ----------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, role)
  values (
    new.id,
    new.email,
    case
      when new.email = 'admin@texno.uz' then 'admin'
      when new.email like '%admin%'      then 'admin'
      else 'skladchi'
    end
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- 4. Mavjud user'lar uchun profil yaratish (bir martagina) ----------
insert into public.profiles (id, email, role)
select
  u.id,
  u.email,
  case
    when u.email = 'admin@texno.uz' then 'admin'
    when u.email like '%admin%'      then 'admin'
    else 'skladchi'
  end
from auth.users u
on conflict (id) do nothing;

-- =========================================================================
-- 5. BIZNES JADVALLARGA RLS
-- Qoidalar:
--   * Hamma autentifikatsiyalangan user -> o'qiy oladi
--   * Hamma autentifikatsiyalangan user -> INSERT qila oladi
--   * Faqat ADMIN -> UPDATE qila oladi
--   * Faqat ADMIN -> DELETE qila oladi
-- =========================================================================

create or replace function public.apply_rbac(tbl regclass)
returns void
language plpgsql
as $$
declare
  schema_name text;
  table_name  text;
begin
  select n.nspname, c.relname
    into schema_name, table_name
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where c.oid = tbl;

  execute format('alter table %I.%I enable row level security;', schema_name, table_name);

  execute format('drop policy if exists "read_authed_%I" on %I.%I;', table_name, schema_name, table_name);
  execute format(
    'create policy "read_authed_%I" on %I.%I for select using (auth.role() = ''authenticated'');',
    table_name, schema_name, table_name
  );

  execute format('drop policy if exists "insert_authed_%I" on %I.%I;', table_name, schema_name, table_name);
  execute format(
    'create policy "insert_authed_%I" on %I.%I for insert with check (auth.role() = ''authenticated'');',
    table_name, schema_name, table_name
  );

  execute format('drop policy if exists "update_admin_only_%I" on %I.%I;', table_name, schema_name, table_name);
  execute format(
    'create policy "update_admin_only_%I" on %I.%I for update using (public.is_admin()) with check (public.is_admin());',
    table_name, schema_name, table_name
  );

  execute format('drop policy if exists "delete_admin_only_%I" on %I.%I;', table_name, schema_name, table_name);
  execute format(
    'create policy "delete_admin_only_%I" on %I.%I for delete using (public.is_admin());',
    table_name, schema_name, table_name
  );
end;
$$;

-- Har bir biznes jadvaliga RBAC qo'llash.
-- Eslatma: agar bu jadvallar hali mavjud bo'lmasa, qatorni vaqtinchalik comment qiling.
select public.apply_rbac('public.categories');
select public.apply_rbac('public.products');
select public.apply_rbac('public.suppliers');
select public.apply_rbac('public.receipt_docs');
select public.apply_rbac('public.receipt_items');
select public.apply_rbac('public.inventory_balances');
select public.apply_rbac('public.inventory_transactions');
select public.apply_rbac('public.write_offs');
select public.apply_rbac('public.write_off_items');

-- =========================================================================
-- TEKSHIRISH
-- =========================================================================
-- Kim qaysi rolda:
--   select email, role from public.profiles order by created_at;
--
-- Birovni adminga aylantirish:
--   update public.profiles set role = 'admin' where email = 'siz@example.com';
-- =========================================================================
