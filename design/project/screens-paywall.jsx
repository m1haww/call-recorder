// Trust/loading + paywall screens

// ─── Notification priming ───
const ScreenNotifications = ({ onNext, onBack }) => (
  <div className="screen">
    <div className="bg-mesh" />
    <BackButton onBack={onBack} />
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', position: 'relative' }}>
      <div className="fade-up" style={{ position: 'relative', display: 'flex', justifyContent: 'center', marginBottom: 36 }}>
        <Glow size={280} opacity={0.3} />
        <div style={{ position: 'relative', width: '100%', maxWidth: 320 }}>
          {/* Mock iOS notification */}
          <div style={{
            background: 'rgba(40, 48, 40, 0.85)',
            backdropFilter: 'blur(20px)',
            borderRadius: 22, padding: '14px 16px',
            border: '1px solid rgba(255,255,255,0.08)',
            boxShadow: '0 24px 60px rgba(0,0,0,0.5)',
            display: 'flex', alignItems: 'center', gap: 12,
            transform: 'rotate(-1.5deg)',
            marginBottom: -12,
          }}>
            <Logo size={36} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 2 }}>
                <span style={{ fontSize: 13, fontWeight: 700 }}>RecallAI</span>
                <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.5)' }}>now</span>
              </div>
              <div style={{ fontSize: 13, fontWeight: 600, color: '#fff' }}>Transcript ready</div>
              <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.6)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                "Q4 contract review" · 18 min · 4 action items
              </div>
            </div>
          </div>
          <div style={{
            background: 'rgba(40, 48, 40, 0.7)',
            backdropFilter: 'blur(20px)',
            borderRadius: 22, padding: '14px 16px',
            border: '1px solid rgba(255,255,255,0.08)',
            display: 'flex', alignItems: 'center', gap: 12,
            transform: 'rotate(0.8deg) translateY(8px)',
            opacity: 0.85,
          }}>
            <Logo size={36} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 2 }}>
                <span style={{ fontSize: 13, fontWeight: 700 }}>RecallAI</span>
                <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.5)' }}>2m</span>
              </div>
              <div style={{ fontSize: 13, fontWeight: 600 }}>Recording saved</div>
              <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.6)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                Sarah · onboarding · synced
              </div>
            </div>
          </div>
        </div>
      </div>

      <Heading
        title="Stay in the loop"
        subtitle="We'll ping you when transcripts are ready."
        align="center"
      />
    </div>
    <div className="fade-up delay-3">
      <button className="cta" onClick={onNext}>Allow Notifications</button>
      <button className="cta cta-secondary" onClick={onNext} style={{ marginTop: 6 }}>Maybe later</button>
    </div>
  </div>
);

// ─── Loading / personalizing ───
const ScreenLoading = ({ onDone }) => {
  const [progress, setProgress] = React.useState(0);
  const [stepIdx, setStepIdx] = React.useState(0);
  const steps = [
    'Recording engine',
    'AI transcription',
    'Secure cloud sync',
    'Personal library',
  ];
  React.useEffect(() => {
    const id = setInterval(() => {
      setProgress(p => {
        const next = p + 1.2;
        if (next >= 100) { clearInterval(id); setTimeout(onDone, 500); return 100; }
        return next;
      });
    }, 35);
    return () => clearInterval(id);
  }, []);
  React.useEffect(() => {
    setStepIdx(Math.min(steps.length - 1, Math.floor(progress / 25)));
  }, [progress]);

  return (
    <div className="screen" style={{ justifyContent: 'center' }}>
      <div className="bg-mesh" />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', position: 'relative' }}>
        <Glow size={280} opacity={0.4} />
        {/* Circular progress */}
        <div style={{ position: 'relative', width: 160, height: 160, marginBottom: 32 }}>
          <svg width="160" height="160" viewBox="0 0 160 160" style={{ transform: 'rotate(-90deg)' }}>
            <circle cx="80" cy="80" r="70" stroke="rgba(255,255,255,0.06)" strokeWidth="4" fill="none"/>
            <circle
              cx="80" cy="80" r="70"
              stroke="url(#prog)" strokeWidth="4" fill="none"
              strokeLinecap="round"
              strokeDasharray={2 * Math.PI * 70}
              strokeDashoffset={2 * Math.PI * 70 * (1 - progress / 100)}
              style={{ transition: 'stroke-dashoffset 0.1s linear', filter: 'drop-shadow(0 0 8px rgba(78,245,66,0.6))' }}
            />
            <defs>
              <linearGradient id="prog" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0%" stopColor="#5fff52"/>
                <stop offset="100%" stopColor="#2bc822"/>
              </linearGradient>
            </defs>
          </svg>
          <div style={{
            position: 'absolute', inset: 0,
            display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
          }}>
            <div style={{ fontSize: 38, fontWeight: 800, letterSpacing: -1.5, color: '#fff' }}>{Math.round(progress)}<span style={{ fontSize: 18, color: 'var(--text-secondary)' }}>%</span></div>
            <div style={{ fontSize: 11, color: 'var(--text-tertiary)', marginTop: 2, letterSpacing: 0.4, textTransform: 'uppercase', fontWeight: 600 }}>Personalizing</div>
          </div>
        </div>

        <h2 style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.6, margin: 0, textAlign: 'center' }}>
          Setting things up
        </h2>

        <div style={{ marginTop: 28, width: '100%', display: 'flex', flexDirection: 'column', gap: 10 }}>
          {steps.map((s, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 12,
              padding: '10px 14px',
              background: i <= stepIdx ? 'rgba(78,245,66,0.06)' : 'transparent',
              borderRadius: 12,
              border: '1px solid ' + (i <= stepIdx ? 'rgba(78,245,66,0.18)' : 'var(--border)'),
              transition: 'all 0.3s',
            }}>
              <div style={{
                width: 22, height: 22, borderRadius: '50%',
                background: i < stepIdx ? 'var(--accent)' : (i === stepIdx ? 'rgba(78,245,66,0.18)' : 'rgba(255,255,255,0.04)'),
                border: i === stepIdx ? '2px solid var(--accent)' : 'none',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                flexShrink: 0,
              }}>
                {i < stepIdx && Icon.check(12, '#062a04')}
                {i === stepIdx && (
                  <div style={{
                    width: 8, height: 8, borderRadius: '50%',
                    border: '2px solid var(--accent)', borderTopColor: 'transparent',
                    animation: 'spin 0.8s linear infinite',
                  }} />
                )}
              </div>
              <div style={{
                fontSize: 13, fontWeight: 500,
                color: i <= stepIdx ? '#fff' : 'var(--text-tertiary)',
                transition: 'color 0.3s',
              }}>{s}</div>
            </div>
          ))}
          <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
        </div>
      </div>
    </div>
  );
};

// ─── Paywall ───
const ScreenPaywall = ({ onClose, onPurchase }) => {
  const [plan, setPlan] = React.useState('annual'); // 'annual' | 'monthly'
  const [trial, setTrial] = React.useState(true);

  return (
    <div className="screen" style={{ padding: '54px 22px 30px' }}>
      <div className="bg-mesh" />

      {/* Close button */}
      <button onClick={onClose} style={{
        position: 'absolute', top: 60, right: 18, zIndex: 10,
        width: 30, height: 30, borderRadius: '50%',
        background: 'rgba(255,255,255,0.08)',
        border: 'none',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer',
      }}>
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.5)" strokeWidth="2.5" strokeLinecap="round">
          <path d="M18 6L6 18M6 6l12 12"/>
        </svg>
      </button>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', overflow: 'hidden' }}>
        {/* Hero */}
        <div className="fade-up" style={{ textAlign: 'center', marginBottom: 18, position: 'relative' }}>
          <Glow size={240} opacity={0.35} />
          <div style={{ position: 'relative', display: 'inline-flex', alignItems: 'center', gap: 6, padding: '5px 12px', borderRadius: 999, background: 'rgba(78,245,66,0.12)', border: '1px solid rgba(78,245,66,0.25)', marginBottom: 14 }}>
            {Icon.sparkle(11)}
            <span style={{ fontSize: 11, fontWeight: 700, color: 'var(--accent)', letterSpacing: 0.4 }}>RECALL PRO</span>
          </div>
          <h1 style={{
            fontSize: 30, fontWeight: 800, lineHeight: 1.05,
            letterSpacing: -1, margin: 0,
          }}>
            Unlock the full<br/>
            <span style={{
              background: 'linear-gradient(180deg, #5fff52 0%, #4ef542 100%)',
              WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
              filter: 'drop-shadow(0 0 16px rgba(78,245,66,0.4))',
            }}>RecallAI experience</span>
          </h1>
        </div>

        {/* Benefits */}
        <div className="fade-up delay-1" style={{ display: 'flex', flexDirection: 'column', gap: 9, marginBottom: 18 }}>
          {[
            { i: Icon.bolt(15, '#062a04'), t: 'Unlimited recordings', s: 'No time limits' },
            { i: Icon.text(15, '#062a04'), t: 'AI transcripts & summaries', s: '30+ languages' },
            { i: Icon.cloud(15, '#062a04'), t: 'Cloud sync', s: 'iPhone, iPad, web' },
            { i: Icon.lock(15, '#062a04'), t: 'Encrypted & private', s: 'Only you can listen' },
          ].map((b, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{
                width: 28, height: 28, borderRadius: 8,
                background: 'linear-gradient(135deg, #4ef542, #2bc822)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                flexShrink: 0,
                boxShadow: '0 4px 12px rgba(78,245,66,0.3)',
              }}>{b.i}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 700, color: '#fff' }}>{b.t}</div>
                <div style={{ fontSize: 12, color: 'var(--text-secondary)' }}>{b.s}</div>
              </div>
            </div>
          ))}
        </div>

        {/* Trial timeline */}
        <div className="fade-up delay-2" style={{
          background: 'var(--bg-surface)',
          border: '1px solid var(--border)',
          borderRadius: 16, padding: 14,
          marginBottom: 14,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
            <div style={{ fontSize: 13, fontWeight: 700 }}>3‑day free trial</div>
            <label style={{ display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer' }}>
              <span style={{ fontSize: 11, color: 'var(--text-secondary)', fontWeight: 500 }}>{trial ? 'On' : 'Off'}</span>
              <div
                onClick={() => setTrial(!trial)}
                style={{
                  width: 36, height: 22, borderRadius: 999,
                  background: trial ? 'var(--accent)' : 'rgba(255,255,255,0.15)',
                  position: 'relative', transition: 'all 0.2s',
                  cursor: 'pointer',
                }}>
                <div style={{
                  position: 'absolute', top: 2, left: trial ? 16 : 2,
                  width: 18, height: 18, borderRadius: '50%',
                  background: '#fff',
                  transition: 'left 0.2s',
                  boxShadow: '0 2px 4px rgba(0,0,0,0.2)',
                }} />
              </div>
            </label>
          </div>
          {/* Mini timeline */}
          <div style={{ display: 'flex', alignItems: 'flex-start', gap: 0 }}>
            {[
              { d: 'Today', t: 'Full access', icon: Icon.lock(10, '#062a04') },
              { d: 'Day 2', t: 'Billing reminder', icon: Icon.bell(10, '#062a04') },
              { d: 'Day 3', t: 'Trial ends', icon: Icon.check(10, '#062a04') },
            ].map((s, i, arr) => (
              <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', position: 'relative' }}>
                <div style={{
                  width: 22, height: 22, borderRadius: '50%',
                  background: i === 0 ? 'var(--accent)' : 'rgba(78,245,66,0.18)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  zIndex: 2, position: 'relative',
                }}>{s.icon}</div>
                {i < arr.length - 1 && (
                  <div style={{
                    position: 'absolute', top: 11, left: '50%', right: '-50%',
                    height: 1.5, background: 'rgba(78,245,66,0.25)', zIndex: 1,
                  }} />
                )}
                <div style={{ fontSize: 10, fontWeight: 700, color: 'var(--accent)', marginTop: 6, letterSpacing: 0.3 }}>{s.d.toUpperCase()}</div>
                <div style={{ fontSize: 10, color: 'var(--text-secondary)', textAlign: 'center', marginTop: 2, lineHeight: 1.2, padding: '0 2px' }}>{s.t}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Plan options */}
        <div className="fade-up delay-3" style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <PlanCard
            id="annual"
            picked={plan === 'annual'}
            onPick={() => setPlan('annual')}
            label="Annual"
            badge="SAVE 67%"
            price="$3.33"
            unit="/wk"
            sub={trial ? '3 days free, then $39.99/year · billed annually' : '$39.99/year · billed annually'}
          />
          <PlanCard
            id="monthly"
            picked={plan === 'monthly'}
            onPick={() => setPlan('monthly')}
            label="Monthly"
            price="$9.99"
            unit="/mo"
            sub="Billed monthly · cancel anytime"
          />
        </div>
      </div>

      {/* CTA */}
      <div className="fade-up delay-4" style={{ marginTop: 14 }}>
        <button className="cta" onClick={onPurchase}>
          {trial && plan === 'annual' ? 'Start 3‑day free trial' : 'Continue'}
        </button>
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          gap: 14, marginTop: 12,
          fontSize: 11, color: 'var(--text-tertiary)',
        }}>
          <span style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
            {Icon.lock(11, 'var(--text-tertiary)')} Cancel anytime
          </span>
          <span>·</span>
          <span style={{ textDecoration: 'underline' }}>Restore</span>
          <span>·</span>
          <span style={{ textDecoration: 'underline' }}>Terms</span>
        </div>
      </div>
    </div>
  );
};

const PlanCard = ({ picked, onPick, label, badge, price, unit, sub }) => (
  <button onClick={onPick} style={{
    display: 'flex', alignItems: 'center', gap: 12,
    padding: '12px 14px', borderRadius: 16,
    background: picked ? 'rgba(78,245,66,0.10)' : 'var(--bg-surface)',
    border: '1.5px solid ' + (picked ? 'var(--accent)' : 'var(--border)'),
    cursor: 'pointer', textAlign: 'left',
    color: '#fff', position: 'relative',
    boxShadow: picked ? '0 0 24px rgba(78,245,66,0.15)' : 'none',
    transition: 'all 0.18s',
  }}>
    <div style={{
      width: 22, height: 22, borderRadius: '50%',
      border: '2px solid ' + (picked ? 'var(--accent)' : 'var(--border-strong)'),
      background: picked ? 'var(--accent)' : 'transparent',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      flexShrink: 0,
    }}>{picked && Icon.check(12, '#062a04')}</div>
    <div style={{ flex: 1 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <span style={{ fontSize: 14, fontWeight: 700 }}>{label}</span>
        {badge && (
          <span style={{
            fontSize: 9, fontWeight: 800,
            padding: '3px 6px', borderRadius: 5,
            background: 'var(--accent)', color: '#062a04',
            letterSpacing: 0.4,
          }}>{badge}</span>
        )}
      </div>
      <div style={{ fontSize: 11, color: 'var(--text-secondary)', marginTop: 1 }}>{sub}</div>
    </div>
    <div style={{ textAlign: 'right' }}>
      <div style={{ fontSize: 17, fontWeight: 800, letterSpacing: -0.4 }}>
        {price}<span style={{ fontSize: 12, fontWeight: 600, color: 'var(--text-secondary)' }}>{unit}</span>
      </div>
    </div>
  </button>
);

// ─── Success / done ───
const ScreenSuccess = ({ onRestart }) => (
  <div className="screen" style={{ justifyContent: 'center' }}>
    <div className="bg-mesh" />
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', position: 'relative' }}>
      <Glow size={300} opacity={0.4} />
      <div className="fade-up" style={{ position: 'relative', marginBottom: 32 }}>
        <PulseRings size={220} />
        <div style={{
          position: 'relative',
          width: 120, height: 120, borderRadius: '50%',
          background: 'radial-gradient(circle at 30% 30%, #5fff52 0%, #2bc822 100%)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 0 60px rgba(78,245,66,0.55), inset 0 2px 0 rgba(255,255,255,0.4)',
        }}>
          {Icon.check(56, '#062a04')}
        </div>
      </div>
      <h1 className="fade-up delay-1" style={{ fontSize: 32, fontWeight: 800, letterSpacing: -1, margin: 0 }}>You're all set!</h1>
      <p className="fade-up delay-2" style={{ fontSize: 16, color: 'var(--text-secondary)', maxWidth: 280, lineHeight: 1.45, marginTop: 12 }}>
        Make your first call.
      </p>
    </div>
    <button className="cta fade-up delay-3" onClick={onRestart}>Open RecallAI</button>
    <div className="fade-up delay-3" style={{ textAlign: 'center', marginTop: 12, fontSize: 11, color: 'var(--text-tertiary)' }}>
      <span style={{ textDecoration: 'underline', cursor: 'pointer' }} onClick={onRestart}>Restart prototype</span>
    </div>
  </div>
);

Object.assign(window, {
  ScreenNotifications, ScreenLoading, ScreenPaywall, ScreenSuccess, PlanCard,
});
