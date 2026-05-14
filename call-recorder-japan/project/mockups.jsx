// In-screen mini phone mockups shown inside onboarding screens.
// These are the "infographic + product-in-context" illustrations Japan
// onboardings rely on (à la YAMAP).

// Mini iPhone bezel
function MiniPhone({ children, width = 240, height = 380, style = {} }) {
  return (
    <div
      className="mini-phone"
      style={{ width, height, ...style }}
    >
      <div
        style={{
          position: 'absolute', top: 8, left: '50%', transform: 'translateX(-50%)',
          width: 70, height: 18, borderRadius: 12, background: '#000', zIndex: 5,
        }}
      />
      <div style={{ width: '100%', height: '100%', position: 'relative', overflow: 'hidden' }}>
        {children}
      </div>
    </div>
  );
}

// Mockup 1 — Active call screen with the recording badge
function CallMockup() {
  return (
    <MiniPhone width={228} height={360}>
      <div style={{
        position: 'absolute', inset: 0,
        background: 'linear-gradient(180deg, #2a3340 0%, #131820 60%, #0a0d12 100%)',
      }} />
      <div className="mini-statusbar">
        <span>9:41</span>
        <span style={{ fontSize: 9, opacity: 0.9 }}>●●●●●</span>
      </div>
      {/* Rec banner */}
      <div style={{
        position: 'absolute', top: 38, left: 16, right: 16,
        display: 'flex', alignItems: 'center', gap: 8,
        background: 'rgba(255,77,79,0.15)', border: '1px solid rgba(255,77,79,0.45)',
        borderRadius: 12, padding: '8px 10px',
      }}>
        <div style={{
          width: 8, height: 8, borderRadius: 99, background: '#ff4d4f',
          boxShadow: '0 0 8px #ff4d4f', animation: 'pulse 1.2s infinite',
        }} />
        <span style={{ fontSize: 10, color: '#ffd9da', fontWeight: 700, letterSpacing: '0.05em' }}>
          録音中 · REC 00:02:48
        </span>
      </div>
      {/* Avatar circle */}
      <div style={{
        position: 'absolute', top: 96, left: '50%', transform: 'translateX(-50%)',
        width: 86, height: 86, borderRadius: 999,
        background: 'linear-gradient(135deg,#3a4a5e,#1e242d)',
        border: '2px solid rgba(255,255,255,0.08)',
        display: 'grid', placeItems: 'center',
        fontSize: 32, fontWeight: 700, color: 'rgba(255,255,255,0.7)',
      }}>
        田
      </div>
      <div style={{
        position: 'absolute', top: 192, left: 0, right: 0, textAlign: 'center', color: '#fff',
      }}>
        <div style={{ fontSize: 14, fontWeight: 700 }}>田中 さん</div>
        <div style={{ fontSize: 10, color: 'rgba(255,255,255,0.55)', marginTop: 2 }}>携帯 · 通話中</div>
      </div>
      {/* Action grid */}
      <div style={{
        position: 'absolute', bottom: 78, left: 0, right: 0,
        display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10, padding: '0 22px',
      }}>
        {['mute','keypad','speaker','add','FaceTime','contacts'].map((l, i) => (
          <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
            <div style={{
              width: 38, height: 38, borderRadius: 999,
              background: 'rgba(255,255,255,0.10)',
              border: '1px solid rgba(255,255,255,0.06)',
            }} />
            <div style={{ fontSize: 8, color: 'rgba(255,255,255,0.5)' }}>{l}</div>
          </div>
        ))}
      </div>
      {/* End call button */}
      <div style={{
        position: 'absolute', bottom: 24, left: '50%', transform: 'translateX(-50%)',
        width: 46, height: 46, borderRadius: 999, background: '#ff3b30',
        display: 'grid', placeItems: 'center', color: 'white', fontSize: 18,
        boxShadow: '0 6px 18px rgba(255,59,48,0.45)',
      }}>📞</div>
      <style>{`
        @keyframes pulse { 0%,100% { opacity: 1 } 50% { opacity: 0.35 } }
      `}</style>
    </MiniPhone>
  );
}

// Mockup 2 — Transcript view (showing AI文字起こし)
function TranscriptMockup() {
  const lines = [
    { who: '田中', t: 'もしもし、お疲れさまです。来週の打ち合わせの件で…', mine: false },
    { who: 'あなた', t: 'はい、水曜日の14時で大丈夫です。', mine: true },
    { who: '田中', t: '承知しました。会議室は本社の3階を予約しておきます。', mine: false },
  ];
  return (
    <MiniPhone width={228} height={360}>
      <div style={{
        position: 'absolute', inset: 0, background: '#0c0f10',
      }} />
      <div className="mini-statusbar">
        <span>9:41</span>
        <span style={{ fontSize: 9, opacity: 0.9 }}>●●●●●</span>
      </div>
      {/* Header */}
      <div style={{
        position: 'absolute', top: 36, left: 14, right: 14,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <div>
          <div style={{ fontSize: 12, fontWeight: 700, color: '#fff' }}>田中 さんとの通話</div>
          <div style={{ fontSize: 9, color: 'rgba(255,255,255,0.4)', marginTop: 2 }}>
            2026/05/13 · 14分 28秒
          </div>
        </div>
        <div style={{
          padding: '4px 8px', borderRadius: 999, fontSize: 8.5, fontWeight: 700,
          background: 'rgba(31,224,122,0.12)', color: '#1FE07A',
          border: '1px solid rgba(31,224,122,0.3)',
        }}>AI 文字起こし</div>
      </div>
      {/* Waveform strip */}
      <div style={{
        position: 'absolute', top: 86, left: 14, right: 14, height: 28,
        display: 'flex', alignItems: 'center', gap: 2,
        background: 'rgba(255,255,255,0.04)', borderRadius: 8, padding: '0 8px',
      }}>
        {Array.from({ length: 40 }).map((_, i) => (
          <div key={i} style={{
            flex: 1, height: `${20 + Math.abs(Math.sin(i * 0.6)) * 80}%`,
            background: i < 20 ? '#1FE07A' : 'rgba(255,255,255,0.18)',
            borderRadius: 1,
          }} />
        ))}
      </div>
      <div style={{
        position: 'absolute', top: 88, right: 18, fontSize: 8.5, color: '#1FE07A', fontWeight: 700,
      }}>0:04 / 14:28</div>
      {/* Transcript lines */}
      <div style={{ position: 'absolute', top: 128, left: 14, right: 14, display: 'flex', flexDirection: 'column', gap: 10 }}>
        {lines.map((l, i) => (
          <div key={i} style={{
            background: l.mine ? 'rgba(31,224,122,0.10)' : 'rgba(255,255,255,0.04)',
            border: l.mine ? '1px solid rgba(31,224,122,0.25)' : '1px solid rgba(255,255,255,0.06)',
            borderRadius: 10, padding: '8px 10px',
          }}>
            <div style={{ fontSize: 8.5, color: l.mine ? '#1FE07A' : 'rgba(255,255,255,0.5)', fontWeight: 700, marginBottom: 3 }}>
              {l.who}
            </div>
            <div style={{ fontSize: 9.5, color: '#fff', lineHeight: 1.5 }}>{l.t}</div>
          </div>
        ))}
      </div>
    </MiniPhone>
  );
}

// Mockup 3 — Summary + search
function SummaryMockup() {
  return (
    <MiniPhone width={228} height={360}>
      <div style={{ position: 'absolute', inset: 0, background: '#0c0f10' }} />
      <div className="mini-statusbar">
        <span>9:41</span>
        <span style={{ fontSize: 9, opacity: 0.9 }}>●●●●●</span>
      </div>
      {/* Search bar */}
      <div style={{
        position: 'absolute', top: 36, left: 14, right: 14, height: 30, borderRadius: 9,
        background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.08)',
        display: 'flex', alignItems: 'center', padding: '0 10px', gap: 8,
      }}>
        <span style={{ fontSize: 11, opacity: 0.5 }}>🔍</span>
        <span style={{ fontSize: 10, color: 'rgba(255,255,255,0.8)' }}>「来週の打ち合わせ」</span>
        <span style={{ marginLeft: 'auto', fontSize: 9, color: '#1FE07A', fontWeight: 700 }}>3件</span>
      </div>
      {/* Summary card */}
      <div style={{
        position: 'absolute', top: 80, left: 14, right: 14, padding: 12,
        background: 'linear-gradient(180deg, rgba(31,224,122,0.10) 0%, rgba(31,224,122,0.04) 100%)',
        border: '1px solid rgba(31,224,122,0.25)', borderRadius: 12,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 6 }}>
          <div style={{ fontSize: 10, color: '#1FE07A', fontWeight: 800 }}>✨ AI 要約</div>
        </div>
        <div style={{ fontSize: 10, color: '#fff', fontWeight: 700, marginBottom: 4, lineHeight: 1.4 }}>
          来週の打ち合わせ調整
        </div>
        <div style={{ fontSize: 9, color: 'rgba(255,255,255,0.7)', lineHeight: 1.55 }}>
          水曜日14時に本社3階の会議室で確定。資料は前日までに送付予定。
        </div>
      </div>
      {/* Action items */}
      <div style={{ position: 'absolute', top: 196, left: 14, right: 14 }}>
        <div style={{ fontSize: 9, color: 'rgba(255,255,255,0.5)', fontWeight: 700, marginBottom: 6 }}>
          アクション項目
        </div>
        {['資料を火曜までに準備', '会議室3階を予約済み', '議事録を共有する'].map((t, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 8, padding: '6px 0',
            borderBottom: i < 2 ? '1px solid rgba(255,255,255,0.05)' : 'none',
          }}>
            <div style={{
              width: 12, height: 12, borderRadius: 3, border: '1.2px solid rgba(255,255,255,0.3)',
              display: 'grid', placeItems: 'center', fontSize: 8, color: '#1FE07A',
            }}>{i === 1 ? '✓' : ''}</div>
            <div style={{ fontSize: 9.5, color: '#fff', textDecoration: i === 1 ? 'line-through' : 'none', opacity: i === 1 ? 0.5 : 1 }}>
              {t}
            </div>
          </div>
        ))}
      </div>
    </MiniPhone>
  );
}

// Mockup 4 — Cloud + sync icon graphic
function CloudGraphic() {
  return (
    <div style={{
      width: 220, height: 220, position: 'relative',
      display: 'grid', placeItems: 'center',
    }}>
      {/* glow */}
      <div style={{
        position: 'absolute', inset: 0, borderRadius: 999,
        background: 'radial-gradient(closest-side, rgba(31,224,122,0.22), transparent 70%)',
      }} />
      {/* rings */}
      {[1,2,3].map((r) => (
        <div key={r} style={{
          position: 'absolute', width: 80 + r*40, height: 80 + r*40, borderRadius: 999,
          border: '1px dashed rgba(31,224,122,0.18)', opacity: 1 - r*0.2,
        }} />
      ))}
      {/* center icon */}
      <div style={{
        width: 86, height: 86, borderRadius: 22,
        background: 'linear-gradient(180deg, #1FE07A 0%, #15a35a 100%)',
        display: 'grid', placeItems: 'center', color: '#04130a',
        boxShadow: '0 12px 28px rgba(31,224,122,0.4)',
        fontSize: 40,
      }}>☁︎</div>
      {/* satellite chips */}
      <div style={{
        position: 'absolute', top: 18, left: 24, padding: '5px 9px', borderRadius: 999,
        background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)',
        fontSize: 10, color: '#fff', fontWeight: 600,
      }}>📞 録音</div>
      <div style={{
        position: 'absolute', top: 24, right: 12, padding: '5px 9px', borderRadius: 999,
        background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)',
        fontSize: 10, color: '#fff', fontWeight: 600,
      }}>📝 文字起こし</div>
      <div style={{
        position: 'absolute', bottom: 18, left: 30, padding: '5px 9px', borderRadius: 999,
        background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)',
        fontSize: 10, color: '#fff', fontWeight: 600,
      }}>✨ 要約</div>
      <div style={{
        position: 'absolute', bottom: 30, right: 24, padding: '5px 9px', borderRadius: 999,
        background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)',
        fontSize: 10, color: '#fff', fontWeight: 600,
      }}>🔍 検索</div>
    </div>
  );
}

// Lock / shield graphic for privacy screen
function PrivacyGraphic() {
  return (
    <div style={{
      width: 220, height: 220, position: 'relative', display: 'grid', placeItems: 'center',
    }}>
      <div style={{
        position: 'absolute', inset: 0, borderRadius: 999,
        background: 'radial-gradient(closest-side, rgba(31,224,122,0.18), transparent 70%)',
      }} />
      {/* shield */}
      <svg width="130" height="150" viewBox="0 0 130 150">
        <defs>
          <linearGradient id="sg" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor="#1FE07A" />
            <stop offset="1" stopColor="#15a35a" />
          </linearGradient>
        </defs>
        <path d="M65 6 L116 24 L116 78 C116 109 95 132 65 144 C35 132 14 109 14 78 L14 24 Z"
          fill="url(#sg)" stroke="rgba(255,255,255,0.15)" strokeWidth="1.5" />
        {/* lock */}
        <rect x="46" y="64" width="38" height="34" rx="6" fill="#04130a" />
        <path d="M52 64 V54 a13 13 0 0 1 26 0 V64" stroke="#04130a" strokeWidth="6" fill="none" />
        <circle cx="65" cy="80" r="4" fill="#1FE07A" />
        <rect x="63" y="80" width="4" height="10" fill="#1FE07A" />
      </svg>
      {/* badge chips */}
      <div style={{
        position: 'absolute', top: 8, right: -4, padding: '4px 9px', borderRadius: 999,
        background: '#fff', color: '#04130a', fontSize: 9.5, fontWeight: 800,
      }}>AES-256</div>
      <div style={{
        position: 'absolute', bottom: 12, left: -8, padding: '4px 9px', borderRadius: 999,
        background: '#fff', color: '#04130a', fontSize: 9.5, fontWeight: 800,
      }}>iCloud 同期</div>
    </div>
  );
}

Object.assign(window, { MiniPhone, CallMockup, TranscriptMockup, SummaryMockup, CloudGraphic, PrivacyGraphic });
