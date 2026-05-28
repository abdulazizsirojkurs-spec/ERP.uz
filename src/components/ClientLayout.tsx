'use client';

import type { ReactNode } from 'react';
import { usePathname } from 'next/navigation';
import Sidebar from '@/components/Sidebar';
import { useAuth } from '@/context/AuthContext';

export default function ClientLayout({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const { user, loading } = useAuth();

  const isLoginPage = pathname === '/login';

  if (loading) {
    return (
      <div
        style={{
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          height: '100vh',
          backgroundColor: '#f1f5f9',
        }}
      >
        Yuklanmoqda...
      </div>
    );
  }

  // Login sahifasi har doim ko'rinadi
  if (isLoginPage) {
    return <>{children}</>;
  }

  // Login qilinmagan user'lar /login'ga yo'naltirilganda bo'sh ekran
  // (yo'naltirishni AuthContext o'zi qiladi)
  if (!user) {
    return null;
  }

  return (
    <div className="app-container">
      <Sidebar />
      <main className="main-content">{children}</main>
    </div>
  );
}
