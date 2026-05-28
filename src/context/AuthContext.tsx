'use client';

import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import { useRouter } from 'next/navigation';
import type { User } from '@supabase/supabase-js';
import { supabase } from '@/utils/supabase';

export type Role = 'admin' | 'skladchi';

type AuthContextType = {
  user: User | null;
  role: Role | null;
  loading: boolean;
  isAdmin: boolean;
  isSkladchi: boolean;
  /** Yangi yozuv yarata oladi (admin ham, skladchi ham). */
  canCreate: boolean;
  /** Mavjud yozuvni tahrirlay oladi (faqat admin). */
  canEdit: boolean;
  /** Yozuvni o'chira oladi (faqat admin). */
  canDelete: boolean;
  signOut: () => Promise<void>;
};

const AuthContext = createContext<AuthContextType>({
  user: null,
  role: null,
  loading: true,
  isAdmin: false,
  isSkladchi: false,
  canCreate: false,
  canEdit: false,
  canDelete: false,
  signOut: async () => {},
});

/**
 * Foydalanuvchi rolini aniqlash.
 * Source of truth — Supabase'dagi `profiles` jadvali.
 * Agar profil hali yaratilmagan bo'lsa (trigger ulgurmagan bo'lsa),
 * email asosida fallback ishlatamiz.
 */
async function resolveRole(userId: string, email?: string | null): Promise<Role> {
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', userId)
      .single();

    if (!error && data?.role === 'admin') return 'admin';
    if (!error && data?.role === 'skladchi') return 'skladchi';
  } catch {
    /* fallback'ga o'tamiz */
  }

  // Profil hali yo'q yoki o'qib bo'lmadi — email asosida taxmin
  // Quyidagi emaillar AVTOMAT admin sifatida tan olinadi:
  const ADMIN_EMAILS = [
    'admin@texno.uz',
    'xontorayevabdulaziz@gmail.com', // sayt egasi
  ];
  if (email && (ADMIN_EMAILS.includes(email.toLowerCase()) || email.includes('admin'))) {
    return 'admin';
  }
  return 'skladchi';
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [role, setRole] = useState<Role | null>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    let mounted = true;

    async function hydrate(nextUser: User | null) {
      if (!mounted) return;
      setUser(nextUser);

      if (!nextUser) {
        setRole(null);
        setLoading(false);
        return;
      }

      const resolved = await resolveRole(nextUser.id, nextUser.email);
      if (!mounted) return;
      setRole(resolved);
      setLoading(false);
    }

    supabase.auth
      .getSession()
      .then(({ data: { session } }) => hydrate(session?.user ?? null))
      .catch((err: unknown) => {
        // eslint-disable-next-line no-console
        console.error('[auth] session olishda xato:', err);
        if (mounted) setLoading(false);
      });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (_event, session) => {
      const nextUser = session?.user ?? null;
      await hydrate(nextUser);
      if (!nextUser) router.push('/login');
    });

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, [router]);

  const signOut = async () => {
    await supabase.auth.signOut();
    setUser(null);
    setRole(null);
    router.push('/login');
  };

  const value = useMemo<AuthContextType>(() => {
    const isAdmin = role === 'admin';
    const isSkladchi = role === 'skladchi';
    return {
      user,
      role,
      loading,
      isAdmin,
      isSkladchi,
      canCreate: isAdmin || isSkladchi,
      canEdit: isAdmin,
      canDelete: isAdmin,
      signOut,
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user, role, loading]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export const useAuth = () => useContext(AuthContext);
