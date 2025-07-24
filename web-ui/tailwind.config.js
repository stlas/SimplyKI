// SimplyKI Web UI - Tailwind Configuration
// Erstellt: 2025-07-24 15:56:00 CEST

/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brain: {
          50: '#fdf4ff',
          100: '#fae8ff',
          200: '#f5d0fe',
          300: '#f0abfc',
          400: '#e879f9',
          500: '#d946ef',
          600: '#c026d3',
          700: '#a21caf',
          800: '#86198f',
          900: '#701a75',
          950: '#4a044e',
        },
        neural: {
          50: '#ecfeff',
          100: '#cffafe',
          200: '#a5f3fc',
          300: '#67e8f9',
          400: '#22d3ee',
          500: '#06b6d4',
          600: '#0891b2',
          700: '#0e7490',
          800: '#155e75',
          900: '#164e63',
          950: '#083344',
        },
        cost: {
          low: '#10b981',    // green
          medium: '#f59e0b', // amber
          high: '#ef4444',   // red
        }
      },
      animation: {
        'pulse-brain': 'pulse-brain 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'neural-flow': 'neural-flow 3s ease-in-out infinite',
      },
      keyframes: {
        'pulse-brain': {
          '0%, 100%': {
            opacity: '1',
            transform: 'scale(1)',
          },
          '50%': {
            opacity: '.7',
            transform: 'scale(1.05)',
          },
        },
        'neural-flow': {
          '0%, 100%': {
            transform: 'translateX(0) translateY(0)',
          },
          '50%': {
            transform: 'translateX(10px) translateY(-5px)',
          },
        }
      },
      fontFamily: {
        'mono': ['JetBrains Mono', 'Fira Code', 'Consolas', 'Monaco', 'monospace'],
      },
      backgroundImage: {
        'neural-gradient': 'radial-gradient(circle at 20% 80%, #d946ef 0%, #06b6d4 50%, #4a044e 100%)',
        'brain-pattern': 'url("data:image/svg+xml,%3Csvg width="60" height="60" viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg"%3E%3Cg fill="none" fill-rule="evenodd"%3E%3Cg fill="%239C92AC" fill-opacity="0.08"%3E%3Cpath d="M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z"/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")',
      },
    },
  },
  plugins: [],
}