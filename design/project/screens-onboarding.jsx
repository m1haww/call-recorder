// Onboarding screens for Call Recorder app

// ─── Screen 1: Welcome / Hero ───
const ScreenWelcome = ({ onNext }) => (
  <div className="screen">
    <div className="bg-mesh" />
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', position: 'relative' }}>
      <Glow size={320} opacity={0.45} />
      {/* Hero visual: stylized phone showing a recording */}
      <div className="fade-up" style={{ position: 'relative', marginBottom: 56 }}>
        <PulseRings size={240} />
        <div style={{
          position: 'relative',
          width: 132, height: 132, borderRadius: '50%',
          background: 'radial-gradient(circle at 30% 30%, #5fff52 0%, #2bc822 100%)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 0 60px rgba(78,245,66,0.55), 0 0 0 1px rgba(78,245,66,0.4), inset 0 2px 0 rgba(255,255,255,0.4)',
        }}>
          <svg width="56" height="56" viewBox="0 0 24 24" fill="#062a04">
            <path d="M12 1a3 3 0 00-3 3v8a3 3 0 006 0V4a3 3 0 00-3-3z"/>
            <path d="M19 10v2a7 7 0 01-14 0v-2" stroke="#062a04" strokeWidth="2" fill="none" strokeLinecap="round"/>
            <path d="M12 19v4M8 23h8" stroke="#062a04" strokeWidth="2" fill="none" strokeLinecap="round"/>
          </svg>
        </div>
      </div>
      <div className="fade-up delay-2" style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 24 }}>
        <Logo size={28} />
        <span style={{ fontSize: 17, fontWeight: 700, letterSpacing: -0.3 }}>RecallAI</span>
      </div>
      <div style={{ textAlign: 'center', maxWidth: 320 }}>
        <h1 className="fade-up delay-2" style={{
          fontSize: 36, fontWeight: 800, lineHeight: 1.05,
          letterSpacing: -1.2, margin: 0,
        }}>
          Never miss a<br />
          <span style={{
            background: 'linear-gradient(180deg, #5fff52 0%, #4ef542 100%)',
            WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
            filter: 'drop-shadow(0 0 24px rgba(78,245,66,0.4))',
          }}>word again</span>
        </h1>
      </div>
    </div>
    <div className="fade-up delay-4">
      <button className="cta" onClick={onNext}>
        Get Started
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#062a04" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" style={{ marginLeft: 8 }}>
          <path d="M5 12h14M13 5l7 7-7 7"/>
        </svg>
      </button>
      <div style={{ textAlign: 'center', marginTop: 16, fontSize: 12, color: 'var(--text-tertiary)', letterSpacing: 0.2 }}>
        By continuing you agree to our <span style={{ color: 'var(--text-secondary)', textDecoration: 'underline' }}>Terms</span> & <span style={{ color: 'var(--text-secondary)', textDecoration: 'underline' }}>Privacy</span>
      </div>
    </div>
  </div>
);

// ─── Screen 2: Social proof ───
const ScreenTrust = ({ onNext, onBack }) => (
  <div className="screen">
    <div className="bg-mesh" />
    <BackButton onBack={onBack} />
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', position: 'relative' }}>
      <div className="fade-up" style={{ textAlign: 'center', marginBottom: 36 }}>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 8, padding: '6px 14px', borderRadius: 999, background: 'rgba(78,245,66,0.1)', border: '1px solid rgba(78,245,66,0.2)', marginBottom: 24 }}>
          <Stars size={12} />
          <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--accent)' }}>4.8 · 38K ratings</span>
        </div>
        <h1 style={{
          fontSize: 30, fontWeight: 800, lineHeight: 1.1,
          letterSpacing: -0.8, margin: 0,
        }}>
          Loved by 2.4M+ users
        </h1>
      </div>

      {/* Stat row */}
      <div className="fade-up delay-2" style={{
        display: 'grid', gridTemplateColumns: '1fr 1fr 1fr',
        gap: 8, marginBottom: 28,
      }}>
        {[
          { v: '120M+', l: 'Calls recorded' },
          { v: '99.2%', l: 'Transcript accuracy' },
          { v: '180+', l: 'Countries' },
        ].map((s, i) => (
          <div key={i} style={{
            background: 'var(--bg-surface)', borderRadius: 16,
            padding: '14px 8px', textAlign: 'center',
            border: '1px solid var(--border)',
          }}>
            <div style={{ fontSize: 18, fontWeight: 800, color: 'var(--accent)', letterSpacing: -0.4 }}>{s.v}</div>
            <div style={{ fontSize: 11, color: 'var(--text-tertiary)', marginTop: 4, lineHeight: 1.2 }}>{s.l}</div>
          </div>
        ))}
      </div>

      {/* Testimonials */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {[
          { name: 'Sarah K.', role: 'Real Estate', text: 'Closed 3 more deals this month.', delay: 'delay-2' },
          { name: 'Marcus T.', role: 'Journalist', text: 'I stopped taking notes entirely.', delay: 'delay-3' },
        ].map((t, i) => (
          <div key={i} className={`fade-up ${t.delay}`} style={{
            background: 'var(--bg-surface)', borderRadius: 18,
            padding: 16, border: '1px solid var(--border)',
          }}>
            <Stars size={11} />
            <div style={{ fontSize: 14, lineHeight: 1.45, margin: '8px 0 10px', color: '#e8efe8' }}>
              "{t.text}"
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 24, height: 24, borderRadius: '50%',
                background: `linear-gradient(135deg, #4ef542, #2bc822)`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 11, fontWeight: 700, color: '#062a04',
              }}>{t.name[0]}</div>
              <div style={{ fontSize: 12, color: 'var(--text-secondary)' }}>
                <strong style={{ color: '#fff' }}>{t.name}</strong> · {t.role}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
    <div className="fade-up delay-4">
      <button className="cta" onClick={onNext}>Continue</button>
      <Dots active={4} total={5} />
    </div>
  </div>
);

// ─── Screen 3: Recording feature ───
const ScreenRecording = ({ onNext, onBack }) => {
  const [isRec, setIsRec] = React.useState(false);
  React.useEffect(() => { const t = setTimeout(() => setIsRec(true), 400); return () => clearTimeout(t); }, []);
  return (
    <div className="screen">
      <div className="bg-mesh" />
      <BackButton onBack={onBack} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', position: 'relative' }}>
        {/* Mock incoming-call card */}
        <div className="fade-up" style={{ position: 'relative', marginBottom: 36 }}>
          <Glow size={320} opacity={0.3} />
          <div style={{
            position: 'relative',
            background: 'linear-gradient(180deg, #1f261f 0%, #161c16 100%)',
            borderRadius: 28, padding: 22,
            border: '1px solid var(--border-strong)',
            boxShadow: '0 24px 60px rgba(0,0,0,0.4), inset 0 1px 0 rgba(255,255,255,0.05)',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 18 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <div style={{
                  width: 42, height: 42, borderRadius: '50%',
                  background: 'linear-gradient(135deg, #6b7280 0%, #374151 100%)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 16, fontWeight: 700, color: '#fff',
                }}>EM</div>
                <div>
                  <div style={{ fontSize: 15, fontWeight: 700 }}>Emily Martinez</div>
                  <div style={{ fontSize: 12, color: 'var(--text-secondary)' }}>Mobile · Outgoing</div>
                </div>
              </div>
              <div style={{
                display: 'flex', alignItems: 'center', gap: 6,
                padding: '5px 10px', borderRadius: 999,
                background: isRec ? 'rgba(255,59,48,0.15)' : 'rgba(255,255,255,0.06)',
                border: '1px solid ' + (isRec ? 'rgba(255,59,48,0.3)' : 'transparent'),
                transition: 'all 0.3s',
              }}>
                <div style={{
                  width: 8, height: 8, borderRadius: '50%',
                  background: isRec ? '#ff3b30' : '#6b7280',
                  animation: isRec ? 'pulseRec 1.4s infinite' : 'none',
                }} />
                <span style={{ fontSize: 11, fontWeight: 700, color: isRec ? '#ff6b63' : 'var(--text-tertiary)', letterSpacing: 0.5 }}>
                  {isRec ? 'REC 02:47' : '00:00'}
                </span>
              </div>
            </div>
            <div style={{
              padding: '14px 4px',
              background: 'rgba(78,245,66,0.04)',
              borderRadius: 16,
              border: '1px solid rgba(78,245,66,0.15)',
            }}>
              <Waveform bars={36} height={48} />
            </div>
            <style>{`@keyframes pulseRec { 0%,100% { opacity: 1; } 50% { opacity: 0.3; } }`}</style>
          </div>
        </div>

        <Heading
          title="One‑tap recording"
          align="center"
        />

        <div className="fade-up delay-3" style={{ display: 'flex', flexWrap: 'wrap', gap: 8, justifyContent: 'center', marginTop: 20 }}>
          <FeaturePill icon={Icon.bolt(13)} text="Auto‑record" />
          <FeaturePill icon={Icon.shield(13)} text="HD quality" />
          <FeaturePill icon={Icon.cloud(13)} text="Cloud backup" />
        </div>
      </div>
      <div className="fade-up delay-4">
        <button className="cta" onClick={onNext}>Continue</button>
        <Dots active={1} total={5} />
      </div>
    </div>
  );
};

// ─── Screen 4: Transcription ───
const ScreenTranscript = ({ onNext, onBack }) => {
  const lines = [
    { who: 'them', text: 'Did you get the proposal?', delay: 0 },
    { who: 'me', text: 'Yes — can we close by Friday?', delay: 800 },
    { who: 'them', text: 'Sending the contract today.', delay: 1700 },
  ];
  const [visible, setVisible] = React.useState(0);
  React.useEffect(() => {
    const timers = lines.map((l, i) => setTimeout(() => setVisible(i + 1), l.delay + 400));
    return () => timers.forEach(clearTimeout);
  }, []);
  return (
    <div className="screen">
      <div className="bg-mesh" />
      <BackButton onBack={onBack} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', position: 'relative' }}>
        <div className="fade-up" style={{ position: 'relative', marginBottom: 32 }}>
          <Glow size={300} opacity={0.25} />
          <div style={{
            position: 'relative',
            background: 'linear-gradient(180deg, #1f261f 0%, #161c16 100%)',
            borderRadius: 24, padding: 18,
            border: '1px solid var(--border-strong)',
            minHeight: 220,
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 14 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '4px 10px', borderRadius: 999, background: 'rgba(78,245,66,0.12)' }}>
                {Icon.sparkle(11)}
                <span style={{ fontSize: 11, fontWeight: 700, color: 'var(--accent)' }}>AI Transcript</span>
              </div>
              <span style={{ fontSize: 11, color: 'var(--text-tertiary)' }}>· Live</span>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {lines.slice(0, visible).map((l, i) => (
                <div key={i} className="fade-up" style={{
                  alignSelf: l.who === 'me' ? 'flex-end' : 'flex-start',
                  maxWidth: '82%',
                  padding: '10px 14px',
                  borderRadius: 16,
                  background: l.who === 'me' ? 'rgba(78,245,66,0.18)' : 'rgba(255,255,255,0.06)',
                  border: l.who === 'me' ? '1px solid rgba(78,245,66,0.3)' : '1px solid var(--border)',
                  fontSize: 13.5, lineHeight: 1.4,
                  color: l.who === 'me' ? '#e8ffd8' : '#e8efe8',
                }}>
                  <div style={{ fontSize: 10, fontWeight: 700, opacity: 0.6, marginBottom: 2, letterSpacing: 0.4 }}>
                    {l.who === 'me' ? 'YOU' : 'EMILY'}
                  </div>
                  {l.text}
                </div>
              ))}
              {visible < lines.length && (
                <div style={{ alignSelf: 'flex-start', display: 'flex', gap: 4, padding: '12px 14px' }}>
                  {[0,1,2].map(i => (
                    <div key={i} style={{
                      width: 6, height: 6, borderRadius: '50%',
                      background: 'var(--accent)',
                      animation: `dotBounce 1s ease-in-out ${i * 0.15}s infinite`,
                    }} />
                  ))}
                  <style>{`@keyframes dotBounce { 0%,80%,100% { opacity: 0.3; transform: translateY(0); } 40% { opacity: 1; transform: translateY(-4px); } }`}</style>
                </div>
              )}
            </div>
          </div>
        </div>

        <Heading
          title="AI transcripts, instantly"
          align="center"
        />
      </div>
      <div className="fade-up delay-4">
        <button className="cta" onClick={onNext}>Continue</button>
        <Dots active={2} total={5} />
      </div>
    </div>
  );
};

// ─── Screen 5: Organization ───
const ScreenOrganize = ({ onNext, onBack }) => {
  const [filter, setFilter] = React.useState('Today');
  const recordings = [
    { name: 'Call Recording', num: '+1 520 244 5872', time: '13:39', dur: '0:08', date: '12 Jun 2025 at 13:43' },
    { name: 'Emily Martinez', num: '+1 415 992 3010', time: '11:02', dur: '18:24', date: '12 Jun 2025 at 11:02' },
  ];
  return (
    <div className="screen">
      <div className="bg-mesh" />
      <BackButton onBack={onBack} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', position: 'relative' }}>
        <div className="fade-up" style={{ marginBottom: 28, position: 'relative' }}>
          <Glow size={300} opacity={0.22} />
          <div style={{ position: 'relative', display: 'flex', flexDirection: 'column', gap: 12 }}>
            {/* Search bar */}
            <div style={{
              display: 'flex', alignItems: 'center', gap: 10,
              padding: '12px 14px',
              background: '#2a322a',
              borderRadius: 14,
            }}>
              {Icon.search(16, 'rgba(255,255,255,0.45)')}
              <span style={{ fontSize: 14, color: 'rgba(255,255,255,0.45)', fontWeight: 500 }}>Search recordings…</span>
            </div>

            {/* Segmented filter */}
            <div style={{
              display: 'flex',
              padding: 3,
              background: '#2a322a',
              borderRadius: 12,
            }}>
              {['All', 'Today', 'Week'].map(f => (
                <button
                  key={f}
                  onClick={() => setFilter(f)}
                  style={{
                    flex: 1, padding: '7px 0',
                    background: filter === f ? 'rgba(78,245,66,0.18)' : 'transparent',
                    border: 'none',
                    borderRadius: 10,
                    color: filter === f ? '#fff' : 'rgba(255,255,255,0.55)',
                    fontWeight: 600, fontSize: 13,
                    cursor: 'pointer',
                    transition: 'all 0.15s',
                    boxShadow: filter === f ? '0 0 12px rgba(78,245,66,0.15)' : 'none',
                  }}
                >{f}</button>
              ))}
            </div>

            {/* Recording cards */}
            {recordings.map((r, i) => (
              <div key={i} className={`fade-up delay-${i + 1}`} style={{
                background: '#1e241e',
                borderRadius: 16,
                padding: 14,
                border: '1px solid rgba(255,255,255,0.04)',
              }}>
                <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12, marginBottom: 10 }}>
                  <div style={{
                    width: 40, height: 40, borderRadius: '50%',
                    background: 'linear-gradient(135deg, #4ef542, #2bc822)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    flexShrink: 0,
                    boxShadow: '0 4px 12px rgba(78,245,66,0.3)',
                  }}>
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="#062a04">
                      <path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45 12.84 12.84 0 002.81.7A2 2 0 0122 16.92z"/>
                    </svg>
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: 16, fontWeight: 700, color: '#fff', letterSpacing: -0.2 }}>{r.name}</div>
                    <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.55)', marginTop: 1 }}>{r.num}</div>
                  </div>
                  <div style={{ textAlign: 'right' }}>
                    <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.55)' }}>{r.time}</div>
                    <div style={{ fontSize: 13, color: 'var(--accent)', fontWeight: 600, marginTop: 1 }}>{r.dur}</div>
                  </div>
                </div>
                <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.4)', marginBottom: 12 }}>{r.date}</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <button style={{
                    flex: 1, height: 38, borderRadius: 999,
                    background: 'rgba(78,245,66,0.85)',
                    border: 'none',
                    color: '#062a04',
                    fontWeight: 700, fontSize: 14,
                    cursor: 'pointer',
                    display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
                    boxShadow: '0 4px 14px rgba(78,245,66,0.25)',
                  }}>
                    <svg width="11" height="12" viewBox="0 0 24 24" fill="#062a04"><polygon points="5 3 19 12 5 21 5 3"/></svg>
                    Play
                  </button>
                  <button style={{
                    width: 38, height: 38, borderRadius: '50%',
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.06)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    cursor: 'pointer',
                  }}>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#4ef542" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M4 12c4-7 12-7 16 0"/>
                      <path d="M16 4l4 4-4 4"/>
                    </svg>
                  </button>
                  <button style={{
                    width: 38, height: 38, borderRadius: '50%',
                    background: 'rgba(255, 80, 70, 0.08)',
                    border: '1px solid rgba(255, 80, 70, 0.12)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    cursor: 'pointer',
                  }}>
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#ff5046" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                      <polyline points="3 6 5 6 21 6"/>
                      <path d="M19 6l-2 14a2 2 0 01-2 2H9a2 2 0 01-2-2L5 6M10 11v6M14 11v6"/>
                      <path d="M8 6V4a2 2 0 012-2h4a2 2 0 012 2v2"/>
                    </svg>
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        <Heading
          title="All calls, organized"
          align="center"
        />
      </div>
      <div className="fade-up delay-4">
        <button className="cta" onClick={onNext}>Continue</button>
        <Dots active={3} total={5} />
      </div>
    </div>
  );
};

// ─── Screen 6: Personalization (commitment device) ───
const ScreenPersonalize = ({ onNext, onBack }) => {
  const [picked, setPicked] = React.useState(null);
  const options = [
    { id: 'work', label: 'Work & meetings', sub: 'Clients, vendors, interviews', icon: Icon.briefcase(20) },
    { id: 'sales', label: 'Sales calls', sub: 'Leads and follow‑ups', icon: Icon.bolt(20) },
    { id: 'legal', label: 'Legal & important', sub: 'Have a record', icon: Icon.scale(20) },
    { id: 'memories', label: 'Personal memories', sub: 'Family & friends', icon: Icon.heart(20) },
  ];
  return (
    <div className="screen">
      <div className="bg-mesh" />
      <BackButton onBack={onBack} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
        <Heading
          title="What will you record?"
        />
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 28 }}>
          {options.map((o, i) => (
            <button
              key={o.id}
              onClick={() => setPicked(o.id)}
              className={`fade-up delay-${i + 1}`}
              style={{
                display: 'flex', alignItems: 'center', gap: 14,
                padding: '14px 16px', borderRadius: 18,
                background: picked === o.id ? 'rgba(78,245,66,0.12)' : 'var(--bg-surface)',
                border: '1.5px solid ' + (picked === o.id ? 'var(--accent)' : 'var(--border)'),
                cursor: 'pointer', textAlign: 'left',
                transition: 'all 0.18s',
                color: '#fff',
                boxShadow: picked === o.id ? '0 0 24px rgba(78,245,66,0.18)' : 'none',
              }}
            >
              <div style={{
                width: 40, height: 40, borderRadius: 10,
                background: picked === o.id ? 'rgba(78,245,66,0.18)' : 'rgba(255,255,255,0.04)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                flexShrink: 0,
              }}>{o.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 700, letterSpacing: -0.2 }}>{o.label}</div>
                <div style={{ fontSize: 12, color: 'var(--text-secondary)', marginTop: 2 }}>{o.sub}</div>
              </div>
              <div style={{
                width: 22, height: 22, borderRadius: '50%',
                border: '2px solid ' + (picked === o.id ? 'var(--accent)' : 'var(--border-strong)'),
                background: picked === o.id ? 'var(--accent)' : 'transparent',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                transition: 'all 0.18s',
              }}>
                {picked === o.id && Icon.check(12, '#062a04')}
              </div>
            </button>
          ))}
        </div>
      </div>
      <div className="fade-up delay-5">
        <button
          className="cta"
          onClick={onNext}
          disabled={!picked}
          style={{
            opacity: picked ? 1 : 0.4,
            cursor: picked ? 'pointer' : 'not-allowed',
            pointerEvents: picked ? 'auto' : 'none',
          }}
        >Continue</button>
        <Dots active={5} total={5} />
      </div>
    </div>
  );
};

// ─── Helper: dots indicator ───
const Dots = ({ active, total }) => (
  <div className="dots" style={{ marginTop: 20 }}>
    {Array.from({length: total}).map((_, i) => (
      <div key={i} className={'dot' + (i + 1 === active ? ' active' : '')} />
    ))}
  </div>
);

// ─── Helper: back button ───
const BackButton = ({ onBack }) => (
  <button onClick={onBack} style={{
    position: 'absolute', top: 64, left: 16, zIndex: 10,
    width: 36, height: 36, borderRadius: '50%',
    background: 'rgba(255,255,255,0.06)',
    border: '1px solid var(--border)',
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    cursor: 'pointer',
  }}>
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.6)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
      <path d="M15 18l-6-6 6-6"/>
    </svg>
  </button>
);

Object.assign(window, {
  ScreenWelcome, ScreenTrust, ScreenRecording, ScreenTranscript,
  ScreenOrganize, ScreenPersonalize, Dots, BackButton,
});
