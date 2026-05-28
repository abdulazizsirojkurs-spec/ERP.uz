'use client';

import type { ReactNode } from 'react';
import { useAuth, type Role } from '@/context/AuthContext';

type Props = {
  /** Ruxsat etilgan rollar. Bo'sh bo'lsa — har qanday autentifikatsiyalangan user. */
  allow?: Role[];
  /** Ruxsat yo'q paytda ko'rsatiladigan element. Default: null (yashirilgan). */
  fallback?: ReactNode;
  children: ReactNode;
};

/**
 * UI-tomondagi rol gate.
 *
 *   <RoleGate allow={['admin']}><DeleteButton /></RoleGate>
 *
 * MUHIM: bu xavfsizlik chizig'i emas — server tomonda (Supabase RLS)
 * bo'lgan tekshiruvni almashtirmaydi. UX uchun foydalaning.
 */
export default function RoleGate({ allow, fallback = null, children }: Props) {
  const { role, loading } = useAuth();

  if (loading) return null;
  if (!role) return <>{fallback}</>;
  if (allow && !allow.includes(role)) return <>{fallback}</>;
  return <>{children}</>;
}
