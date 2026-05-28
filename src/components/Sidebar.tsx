'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  Home,
  Package,
  ShoppingCart,
  DollarSign,
  LogOut,
  ShieldCheck,
  User,
  type LucideIcon,
} from 'lucide-react';
import { useAuth, type Role } from '@/context/AuthContext';

type NavItem = {
  name: string;
  href: string;
  icon: LucideIcon;
  /** Ruxsat etilgan rollar. Undefined = barcha autentifikatsiyalanganlar. */
  allow?: Role[];
};

const navItems: NavItem[] = [
  { name: 'Dashboard', href: '/', icon: Home, allow: ['admin'] },
  { name: 'Sotuv', href: '/sales', icon: ShoppingCart, allow: ['admin'] },
  { name: 'Ombor', href: '/warehouse', icon: Package, allow: ['admin', 'skladchi'] },
  { name: 'Moliya', href: '/finance', icon: DollarSign, allow: ['admin'] },
];

export default function Sidebar() {
  const pathname = usePathname();
  const { user, role, isAdmin, signOut } = useAuth();

  const visibleItems = navItems.filter((item) => {
    if (!item.allow) return true;
    return role !== null && item.allow.includes(role);
  });

  return (
    <aside className="sidebar">
      <div className="sidebar-header">Texno Optom</div>

      <nav className="sidebar-nav">
        {visibleItems.map((item) => {
          const Icon = item.icon;
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`nav-item ${isActive ? 'active' : ''}`}
            >
              <Icon size={20} />
              {item.name}
            </Link>
          );
        })}
      </nav>

      {/* Pastdagi user kartochkasi */}
      <div
        style={{
          marginTop: 'auto',
          padding: '16px',
          borderTop: '1px solid var(--border)',
          display: 'flex',
          flexDirection: 'column',
          gap: '10px',
        }}
      >
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            fontSize: '0.85rem',
            color: 'var(--text-secondary)',
          }}
        >
          {isAdmin ? <ShieldCheck size={16} /> : <User size={16} />}
          <div style={{ overflow: 'hidden' }}>
            <div
              style={{
                fontWeight: 600,
                color: 'var(--text-primary)',
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
              }}
            >
              {user?.email ?? '—'}
            </div>
            <div
              style={{
                fontSize: '0.75rem',
                textTransform: 'uppercase',
                letterSpacing: '0.05em',
                color: isAdmin ? '#15803d' : '#1d4ed8',
                fontWeight: 600,
              }}
            >
              {role ?? '...'}
            </div>
          </div>
        </div>

        <button
          onClick={signOut}
          className="btn"
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            padding: '8px 12px',
            backgroundColor: '#fee2e2',
            color: '#b91c1c',
            border: '1px solid #fca5a5',
            borderRadius: '6px',
            fontSize: '0.85rem',
            fontWeight: 600,
          }}
        >
          <LogOut size={16} /> Chiqish
        </button>
      </div>
    </aside>
  );
}
