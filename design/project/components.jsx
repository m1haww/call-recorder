// Shared UI bits: glow logo, phone mock, transcript, etc.

const Glow = ({ size = 220, opacity = 0.35 }) => (
  <div style={{
    position: 'absolute',
    width: size, height: size,
    borderRadius: '50%',
    background: 'radial-gradient(circle, rgba(78,245,66,' + opacity + ') 0%, transparent 60%)',
    pointerEvents: 'none', filter: 'blur(20px)',
  }} />
);

// Brand mark
const Logo = ({ size = 36 }) => (
  <div style={{
    width: size, height: size, borderRadius: size * 0.28,
    background: 'linear-gradient(135deg, #4ef542 0%, #2bc822 100%)',
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    boxShadow: '0 4px 14px rgba(78,245,66,0.4), inset 0 1px 0 rgba(255,255,255,0.3)',
    flexShrink: 0,
  }}>
    <svg width={size * 0.55} height={size * 0.55} viewBox="0 0 24 24" fill="none">
      <path d="M5 4.5C5 3.67 5.67 3 6.5 3h2.5c.83 0 1.5.67 1.5 1.5v3c0 .83-.67 1.5-1.5 1.5H8c-.55 4.5 3 8 7.5 7.5v-1c0-.83.67-1.5 1.5-1.5h3c.83 0 1.5.67 1.5 1.5V17c0 2.21-1.79 4-4 4-9.39 0-17-7.61-17-17 0-2.21 1.79-4 4-4z" fill="#062a04"/>
    </svg>
  </div>
);

// Animated waveform (CSS-only)
const Waveform = ({ bars = 32, height = 60, color = '#4ef542' }) => {
  const pattern = React.useMemo(() => {
    const arr = [];
    for (let i = 0; i < bars; i++) {
      const v = 0.3 + Math.abs(Math.sin(i * 0.6)) * 0.5 + Math.abs(Math.sin(i * 1.7)) * 0.3;
      arr.push(Math.min(1, v));
    }
    return arr;
  }, [bars]);
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 3,
      height, width: '100%', justifyContent: 'center',
    }}>
      {pattern.map((h, i) => (
        <div key={i} style={{
          width: 3, height: '100%',
          background: color, borderRadius: 2,
          transform: `scaleY(${h})`,
          animation: `wave ${0.8 + (i % 4) * 0.15}s ease-in-out ${i * 0.04}s infinite`,
          transformOrigin: 'center',
          opacity: 0.3 + h * 0.7,
          boxShadow: `0 0 ${4 + h * 8}px rgba(78,245,66,${h * 0.4})`,
        }} />
      ))}
    </div>
  );
};

// Concentric pulse rings around an icon
const PulseRings = ({ size = 220 }) => (
  <div style={{ position: 'absolute', width: size, height: size, pointerEvents: 'none' }}>
    {[0, 1, 2].map(i => (
      <div key={i} style={{
        position: 'absolute', inset: 0,
        borderRadius: '50%',
        border: '1px solid rgba(78,245,66,0.3)',
        animation: `ringPulse 3s ease-out ${i * 1}s infinite`,
      }} />
    ))}
    <style>{`
      @keyframes ringPulse {
        0% { transform: scale(0.6); opacity: 0.8; }
        100% { transform: scale(1.4); opacity: 0; }
      }
    `}</style>
  </div>
);

// Section heading
const Heading = ({ title, subtitle, align = 'left' }) => (
  <div style={{ textAlign: align }}>
    <h1 className="fade-up" style={{
      fontSize: 30, fontWeight: 700, lineHeight: 1.1,
      letterSpacing: -0.8, margin: 0, color: '#fff',
    }}>{title}</h1>
    {subtitle && (
      <p className="fade-up delay-1" style={{
        fontSize: 16, fontWeight: 400, lineHeight: 1.45,
        color: 'var(--text-secondary)', margin: '12px 0 0',
        letterSpacing: -0.1,
      }}>{subtitle}</p>
    )}
  </div>
);

// Star rating
const Stars = ({ size = 14, count = 5, fill = '#4ef542' }) => (
  <div style={{ display: 'flex', gap: 2 }}>
    {Array.from({length: count}).map((_, i) => (
      <svg key={i} width={size} height={size} viewBox="0 0 24 24" fill={fill}>
        <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
      </svg>
    ))}
  </div>
);

// Reusable feature pill
const FeaturePill = ({ icon, text }) => (
  <div style={{
    display: 'inline-flex', alignItems: 'center', gap: 8,
    padding: '8px 14px',
    borderRadius: 999,
    background: 'rgba(78,245,66,0.12)',
    border: '1px solid rgba(78,245,66,0.25)',
    color: '#4ef542',
    fontSize: 13, fontWeight: 600,
  }}>
    {icon}
    <span>{text}</span>
  </div>
);

// Icon library (line icons)
const Icon = {
  phone: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45 12.84 12.84 0 002.81.7A2 2 0 0122 16.92z"/>
    </svg>
  ),
  mic: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 1a3 3 0 00-3 3v8a3 3 0 006 0V4a3 3 0 00-3-3z"/>
      <path d="M19 10v2a7 7 0 01-14 0v-2M12 19v4M8 23h8"/>
    </svg>
  ),
  text: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 6h16M4 12h12M4 18h8"/>
    </svg>
  ),
  folder: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M22 19a2 2 0 01-2 2H4a2 2 0 01-2-2V5a2 2 0 012-2h5l2 3h9a2 2 0 012 2z"/>
    </svg>
  ),
  shield: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
    </svg>
  ),
  cloud: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M18 10h-1.26A8 8 0 109 20h9a5 5 0 000-10z"/>
    </svg>
  ),
  search: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="11" cy="11" r="8"/>
      <path d="M21 21l-4.35-4.35"/>
    </svg>
  ),
  bolt: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
    </svg>
  ),
  briefcase: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="2" y="7" width="20" height="14" rx="2"/>
      <path d="M16 21V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v16"/>
    </svg>
  ),
  user: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
      <circle cx="12" cy="7" r="4"/>
    </svg>
  ),
  scale: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 3v18M5 7l7-4 7 4M3 13l4-6 4 6M13 13l4-6 4 6"/>
    </svg>
  ),
  heart: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"/>
    </svg>
  ),
  bell: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M18 8a6 6 0 00-12 0c0 7-3 9-3 9h18s-3-2-3-9M13.73 21a2 2 0 01-3.46 0"/>
    </svg>
  ),
  check: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M20 6L9 17l-5-5"/>
    </svg>
  ),
  lock: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="11" width="18" height="11" rx="2"/>
      <path d="M7 11V7a5 5 0 0110 0v4"/>
    </svg>
  ),
  sparkle: (s = 22, c = '#4ef542') => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill={c}>
      <path d="M12 2l1.7 5.3L19 9l-5.3 1.7L12 16l-1.7-5.3L5 9l5.3-1.7L12 2zM5 16l.85 2.65L8.5 19.5l-2.65.85L5 23l-.85-2.65L1.5 19.5l2.65-.85L5 16zM19 14l1 2.5 2.5 1-2.5 1L19 21l-1-2.5-2.5-1 2.5-1L19 14z"/>
    </svg>
  ),
};

Object.assign(window, { Glow, Logo, Waveform, PulseRings, Heading, Stars, FeaturePill, Icon });
