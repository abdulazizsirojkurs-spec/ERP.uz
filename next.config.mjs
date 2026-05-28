/** @type {import('next').NextConfig} */
const nextConfig = {
  // Vercel build paytida lint xato bermay ishlasin (warning'lar tuzatish kerak,
  // lekin deploy'ni to'xtatmasligi kerak).
  eslint: {
    ignoreDuringBuilds: true,
  },
  // TypeScript xatolar deploy'ni to'xtatadi — bu xohlanadigan holat.
  typescript: {
    ignoreBuildErrors: false,
  },
  // Supabase storage'dan kelayotgan rasmlar uchun ruxsat.
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '*.supabase.co',
      },
    ],
  },
};

export default nextConfig;
