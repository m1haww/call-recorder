// Main app: holds screen state, renders centered iPhone with controls outside.

const SCREENS = [
  { id: 'welcome',    label: 'Welcome' },
  { id: 'record',     label: 'Record' },
  { id: 'transcribe', label: 'Transcribe' },
  { id: 'summary',    label: 'Summary' },
  { id: 'privacy',    label: 'Privacy' },
  { id: 'usecase',    label: 'Use case' },
  { id: 'cloud',      label: 'Cloud' },
  { id: 'paywall',    label: 'Paywall' },
];
const ONBOARDING_COUNT = 7; // welcome…cloud

function PaywallSuccess({ onReset }) {
  return (
    <div className="screen-key" style={{
      height: '100%', display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center',
      padding: 32, textAlign: 'center', paddingTop: 80,
    }}>
      <div style={{
        width: 92, height: 92, borderRadius: 999,
        background: 'linear-gradient(180deg, #1FE07A, #15a35a)',
        display: 'grid', placeItems: 'center', color: '#04130a',
        fontSize: 48, fontWeight: 900,
        boxShadow: '0 18px 40px rgba(31,224,122,0.45)',
        marginBottom: 24,
      }}>✓</div>
      <span className="ja-tag" style={{ marginBottom: 12 }}>ご登録ありがとうございます</span>
      <h1 style={{ fontSize: 24, fontWeight: 900, lineHeight: 1.35, margin: '0 0 12px' }}>
        プレミアムへ、<br/>ようこそ。
      </h1>
      <p className="ja-body" style={{ maxWidth: 280 }}>
        3日間の無料トライアルが開始されました。<br/>
        さっそく最初の通話を録音してみましょう。
      </p>
      <div style={{ height: 28 }} />
      <button className="cta" onClick={onReset} style={{ maxWidth: 280 }}>
        アプリを開始する <span style={{ marginLeft: 4 }}>→</span>
      </button>
    </div>
  );
}

function App() {
  const [idx, setIdx] = React.useState(0);
  const [done, setDone] = React.useState(false);

  const goto = (n) => setIdx(Math.max(0, Math.min(SCREENS.length - 1, n)));
  const next = () => goto(idx + 1);
  const back = () => goto(idx - 1);

  const reset = () => { setIdx(0); setDone(false); };

  const screenName = SCREENS[idx].label;
  const id = SCREENS[idx].id;

  const onboardingIdx = idx; // 0..6 for onboarding screens

  let body;
  if (done) {
    body = <PaywallSuccess onReset={reset} />;
  } else if (id === 'welcome') {
    body = <S1Welcome next={next} total={ONBOARDING_COUNT} />;
  } else if (id === 'record') {
    body = <S2Record next={next} idx={onboardingIdx} total={ONBOARDING_COUNT} />;
  } else if (id === 'transcribe') {
    body = <S3Transcribe next={next} idx={onboardingIdx} total={ONBOARDING_COUNT} />;
  } else if (id === 'summary') {
    body = <S4Summary next={next} idx={onboardingIdx} total={ONBOARDING_COUNT} />;
  } else if (id === 'privacy') {
    body = <S5Privacy next={next} idx={onboardingIdx} total={ONBOARDING_COUNT} />;
  } else if (id === 'usecase') {
    body = <S6UseCase next={next} idx={onboardingIdx} total={ONBOARDING_COUNT} />;
  } else if (id === 'cloud') {
    body = <S7Cloud next={next} idx={onboardingIdx} total={ONBOARDING_COUNT} />;
  } else if (id === 'paywall') {
    body = <Paywall onClose={reset} onUpgrade={() => setDone(true)} />;
  }

  return (
    <>
      {/* Header strip */}
      <div className="frame-header">
        <span className="dot" />
        <span>Call Recorder · <b>Japan localization</b></span>
        <span className="sep" />
        <span>Onboarding (7) + Long-form Paywall</span>
        <span className="sep" />
        <span>Tap CTAs inside the device — or use ← → buttons</span>
      </div>

      <div className="stage">
        <button className="nav-btn" onClick={back} disabled={idx === 0 || done} aria-label="Previous">←</button>

        <IOSDevice width={402} height={874} dark={true}>
          {body}
        </IOSDevice>

        <button className="nav-btn" onClick={next} disabled={idx === SCREENS.length - 1 || done} aria-label="Next">→</button>
      </div>

      {/* Progress + step labels */}
      <div className="progress">
        <span className="label">
          {done ? 'Subscribed ✓' : `${String(idx + 1).padStart(2, '0')} · ${screenName}`}
        </span>
        {SCREENS.map((s, i) => (
          <div key={s.id}
            onClick={() => { setDone(false); goto(i); }}
            className={`seg ${i === idx && !done ? 'active' : ''}`}
            style={{
              width: i === idx && !done ? 28 : 14,
              cursor: 'pointer',
              background: done ? 'var(--accent)' : (i <= idx ? 'rgba(31,224,122,0.6)' : 'rgba(255,255,255,0.14)'),
            }}
            title={s.label}
          />
        ))}
      </div>

      <div className="foot">
        Onboarding follows the Japanese pattern: <b>small tag → detailed 2-line headline → body → bullet reassurances</b>,
        each screen anchored by a product-in-context mockup. The paywall is a single scrollable surface with
        numbered benefits, ○/× comparison, plan select, testimonials, security badges and FAQ — designed for
        the slower-to-convert / higher-retention Japanese user.
      </div>
    </>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
