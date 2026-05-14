// Onboarding screens — Japan-localized.
// Each screen follows the YAMAP/Japanese pattern:
//   1) small context tag       (e.g. "STEP 02 · 通話録音")
//   2) detailed 2-line headline (the "what" + the "how")
//   3) body paragraph that explains and reassures
//   4) feature bullets (○ checks)
//   5) in-context infographic / product mockup
// Followed by a primary CTA + optional "skip / 後で" link.

// Layout shell every onboarding screen uses
function OnbShell({ tag, headline, body, bullets, art, cta = '次へ', onNext, onBack, secondary, onSecondary, idx, total }) {
  return (
    <div className="screen-key" style={{
      height: '100%', display: 'flex', flexDirection: 'column',
      paddingTop: 58,
    }}>
      {/* Top bar: progress + step counter */}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10, padding: '8px 22px 0',
      }}>
        <div style={{ flex: 1, display: 'flex', gap: 4 }}>
          {Array.from({ length: total }).map((_, i) => (
            <div key={i} style={{
              flex: 1, height: 3, borderRadius: 99,
              background: i <= idx ? 'var(--accent)' : 'rgba(255,255,255,0.12)',
              transition: 'background 0.3s',
            }} />
          ))}
        </div>
        <div style={{ fontSize: 10.5, color: 'var(--ink-3)', fontVariantNumeric: 'tabular-nums', letterSpacing: '0.05em', fontWeight: 600 }}>
          {String(idx + 1).padStart(2, '0')} / {String(total).padStart(2, '0')}
        </div>
      </div>

      {/* Art / mockup region */}
      <div style={{
        display: 'grid', placeItems: 'center',
        padding: '20px 22px 4px', minHeight: 240,
      }}>
        {art}
      </div>

      {/* Text body — scrollable if needed */}
      <div className="phone-scroll" style={{ flex: 1, overflow: 'auto', padding: '8px 22px 0' }}>
        <span className="ja-tag">{tag}</span>
        <h1 className="ja-headline">{headline}</h1>
        <p className="ja-body">{body}</p>
        {bullets && (
          <ul className="feature-bullets">
            {bullets.map((b, i) => (
              <li key={i}>
                <span className="check">✓</span>
                <div>
                  {b.t}
                  {b.sub && <small>{b.sub}</small>}
                </div>
              </li>
            ))}
          </ul>
        )}
        <div style={{ height: 20 }} />
      </div>

      {/* CTA region */}
      <div style={{ padding: '12px 22px 32px' }}>
        <button className="cta" onClick={onNext}>
          {cta} <span style={{ marginLeft: 4 }}>→</span>
        </button>
        {secondary && (
          <button className="cta ghost" onClick={onSecondary} style={{ marginTop: 4 }}>
            {secondary}
          </button>
        )}
      </div>
    </div>
  );
}

// ─── Screen 1 — Welcome / Hero ──────────────────────────────────
function S1Welcome({ next, total }) {
  return (
    <div className="screen-key" style={{ height: '100%', display: 'flex', flexDirection: 'column', paddingTop: 58 }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '20px 28px', textAlign: 'center' }}>
        {/* App icon */}
        <div style={{
          width: 92, height: 92, borderRadius: 22, background: '#000',
          border: '1px solid rgba(255,255,255,0.08)',
          display: 'grid', placeItems: 'center', position: 'relative',
          boxShadow: '0 20px 40px rgba(0,0,0,0.6)', marginBottom: 22,
        }}>
          <svg width="48" height="48" viewBox="0 0 64 64">
            <path d="M14 18 C14 14 17 12 21 14 L28 18 C31 20 32 24 30 27 L26 33 C29 38 34 43 39 46 L45 42 C48 40 52 41 54 44 L58 51 C60 55 58 58 54 58 L50 58 C30 58 14 42 14 22 Z" fill="#1FE07A"/>
          </svg>
          <div style={{
            position: 'absolute', top: -6, right: -6, width: 28, height: 28, borderRadius: 999,
            background: '#ff3b30', display: 'grid', placeItems: 'center',
            fontSize: 9, fontWeight: 900, color: 'white', letterSpacing: '0.04em',
            boxShadow: '0 6px 14px rgba(255,59,48,0.5)',
          }}>REC</div>
        </div>
        <span className="ja-tag" style={{ marginBottom: 14 }}>ようこそ · WELCOME</span>
        <h1 style={{
          fontSize: 28, fontWeight: 900, lineHeight: 1.3, margin: '0 0 14px',
          letterSpacing: '-0.01em',
        }}>
          大切な通話を、<br/>
          <span style={{ color: 'var(--accent)' }}>一言も逃さない。</span>
        </h1>
        <p className="ja-body" style={{ maxWidth: 280 }}>
          仕事の打ち合わせも、家族との会話も。<br/>
          高音質で録音し、AIが文字に起こします。
        </p>
        <div style={{
          marginTop: 22, display: 'flex', gap: 14, alignItems: 'center', justifyContent: 'center',
          color: 'var(--ink-2)', fontSize: 11,
        }}>
          <span>★★★★★</span>
          <span style={{ width: 1, height: 10, background: 'rgba(255,255,255,0.2)' }} />
          <span><b style={{ color: 'var(--ink)' }}>4.8</b> · 12,400件のレビュー</span>
        </div>
      </div>
      <div style={{ padding: '12px 22px 32px' }}>
        <button className="cta" onClick={next}>はじめる <span style={{ marginLeft: 4 }}>→</span></button>
        <div style={{
          marginTop: 14, textAlign: 'center', fontSize: 10.5, color: 'var(--ink-3)', lineHeight: 1.6,
        }}>
          続行することで <span style={{ color: 'var(--ink-2)' }}>利用規約</span> と<br/>
          <span style={{ color: 'var(--ink-2)' }}>プライバシーポリシー</span> に同意したものとします。
        </div>
      </div>
    </div>
  );
}

// ─── Screen 2 — Record ─────────────────────────────────────────
function S2Record({ next, idx, total }) {
  return (
    <OnbShell
      idx={idx} total={total}
      tag="STEP 01 · 通話録音"
      art={<CallMockup />}
      headline={<>ワンタップで、<br/>発信・着信を高音質録音。</>}
      body="iPhone の通話画面から、いつもの操作で録音を開始できます。会議・商談・カスタマーサポートなど、聞き逃したくない場面に。"
      bullets={[
        { t: '発信・着信どちらにも対応', sub: '通常の電話・IP電話・国際電話すべて録音可能' },
        { t: '最大 48kHz / 320kbps の高音質保存', sub: '相手の声もこちら側もクリアに残ります' },
        { t: '長時間の通話でも安定動作', sub: '何時間でも途切れず保存（容量の許す限り）' },
      ]}
      cta="次へ"
      onNext={next}
    />
  );
}

// ─── Screen 3 — Transcribe ─────────────────────────────────────
function S3Transcribe({ next, idx, total }) {
  return (
    <OnbShell
      idx={idx} total={total}
      tag="STEP 02 · AI 文字起こし"
      art={<TranscriptMockup />}
      headline={<>録音した会話を、<br/>自動でテキストに変換。</>}
      body="日本語に最適化された音声認識エンジンが、敬語・専門用語・話者の切り替えまで正確に書き起こします。聞き直す手間がなくなります。"
      bullets={[
        { t: '日本語ネイティブ精度の文字起こし', sub: '業界用語・固有名詞も学習済みのモデル' },
        { t: '話者ごとに自動で分けて表示', sub: '誰が何を話したか一目で確認できます' },
        { t: '英語・中国語・韓国語にも対応', sub: '海外との通話も同じ精度でテキスト化' },
      ]}
      cta="次へ"
      onNext={next}
    />
  );
}

// ─── Screen 4 — Summarize & Search ─────────────────────────────
function S4Summary({ next, idx, total }) {
  return (
    <OnbShell
      idx={idx} total={total}
      tag="STEP 03 · 要約 & 検索"
      art={<SummaryMockup />}
      headline={<>長い通話も、<br/>要点だけ 3 秒で把握。</>}
      body="AI が通話内容を要約し、決定事項やタスクを自動で抽出します。あとから「あの話、何だったっけ？」を全文検索で一発解決。"
      bullets={[
        { t: 'ワンクリックで自動要約', sub: '15分の通話を3行のサマリーに' },
        { t: 'アクション項目を自動抽出', sub: '「〜する」を ToDo リストに変換' },
        { t: '全文検索で過去の通話から発見', sub: 'キーワードを含む録音をすぐに呼び出せます' },
      ]}
      cta="次へ"
      onNext={next}
    />
  );
}

// ─── Screen 5 — Privacy & Security ─────────────────────────────
function S5Privacy({ next, idx, total }) {
  return (
    <OnbShell
      idx={idx} total={total}
      tag="STEP 04 · プライバシー"
      art={<PrivacyGraphic />}
      headline={<>あなたの録音は、<br/>あなただけのもの。</>}
      body="すべての録音とテキストは、業界標準の AES-256 で暗号化され、お客様の許可なく外部に共有されることはありません。安心してお使いください。"
      bullets={[
        { t: '端末内 & iCloud の両方で暗号化保存', sub: '通信経路もエンドツーエンドで保護' },
        { t: '広告目的でデータを共有しません', sub: '第三者への販売・提供は一切ありません' },
        { t: 'いつでもデータを完全削除できます', sub: '退会時はすべての録音が30日以内に消去されます' },
        { t: '日本の個人情報保護法に準拠', sub: 'プライバシーポリシーで全項目を開示しています' },
      ]}
      cta="次へ"
      onNext={next}
    />
  );
}

// ─── Screen 6 — Use case selection ─────────────────────────────
function S6UseCase({ next, idx, total }) {
  const [pick, setPick] = React.useState('work');
  const cases = [
    { id: 'work', emoji: '💼', t: '仕事 · ビジネス', sub: '商談・会議・カスタマー対応の記録に' },
    { id: 'personal', emoji: '🏠', t: '個人 · 日常生活', sub: '家族との約束・大事な連絡を残したい' },
    { id: 'study', emoji: '🎓', t: '勉強 · インタビュー', sub: '取材・学習・語学練習の振り返りに' },
  ];
  return (
    <div className="screen-key" style={{ height: '100%', display: 'flex', flexDirection: 'column', paddingTop: 58 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '8px 22px 0' }}>
        <div style={{ flex: 1, display: 'flex', gap: 4 }}>
          {Array.from({ length: total }).map((_, i) => (
            <div key={i} style={{
              flex: 1, height: 3, borderRadius: 99,
              background: i <= idx ? 'var(--accent)' : 'rgba(255,255,255,0.12)',
              transition: 'background 0.3s',
            }} />
          ))}
        </div>
        <div style={{ fontSize: 10.5, color: 'var(--ink-3)', fontVariantNumeric: 'tabular-nums', letterSpacing: '0.05em', fontWeight: 600 }}>
          {String(idx + 1).padStart(2, '0')} / {String(total).padStart(2, '0')}
        </div>
      </div>

      <div className="phone-scroll" style={{ flex: 1, overflow: 'auto', padding: '28px 22px 0' }}>
        <span className="ja-tag">STEP 05 · 用途を教えてください</span>
        <h1 className="ja-headline">
          どんな場面で<br/>使う予定ですか？
        </h1>
        <p className="ja-body" style={{ marginBottom: 18 }}>
          選んだ用途に合わせて、最適な機能と通知設定をご提案します。<br/>あとから設定画面でいつでも変更できます。
        </p>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {cases.map((c) => {
            const active = pick === c.id;
            return (
              <button key={c.id} onClick={() => setPick(c.id)}
                style={{
                  display: 'flex', alignItems: 'center', gap: 12,
                  padding: '14px 14px', borderRadius: 14,
                  background: active ? 'rgba(31,224,122,0.10)' : 'var(--card)',
                  border: active ? '1.5px solid var(--accent)' : '1px solid var(--line)',
                  color: 'var(--ink)', textAlign: 'left', cursor: 'pointer',
                  fontFamily: 'inherit', transition: 'all 0.15s',
                }}>
                <div style={{
                  width: 40, height: 40, borderRadius: 10,
                  background: active ? 'var(--accent)' : 'rgba(255,255,255,0.05)',
                  display: 'grid', placeItems: 'center', fontSize: 20, flex: 'none',
                }}>{c.emoji}</div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 700 }}>{c.t}</div>
                  <div style={{ fontSize: 11.5, color: 'var(--ink-2)', marginTop: 2, lineHeight: 1.5 }}>{c.sub}</div>
                </div>
                <div style={{
                  width: 22, height: 22, borderRadius: 999,
                  border: active ? 'none' : '1.5px solid rgba(255,255,255,0.2)',
                  background: active ? 'var(--accent)' : 'transparent',
                  color: 'var(--accent-ink)', display: 'grid', placeItems: 'center',
                  fontSize: 12, fontWeight: 900,
                }}>{active ? '✓' : ''}</div>
              </button>
            );
          })}
        </div>
        <div style={{ height: 20 }} />
      </div>

      <div style={{ padding: '12px 22px 32px' }}>
        <button className="cta" onClick={next}>選択して次へ <span style={{ marginLeft: 4 }}>→</span></button>
      </div>
    </div>
  );
}

// ─── Screen 7 — Cloud / Ready ──────────────────────────────────
function S7Cloud({ next, idx, total }) {
  return (
    <OnbShell
      idx={idx} total={total}
      tag="STEP 06 · クラウド同期"
      art={<CloudGraphic />}
      headline={<>すべての通話を、<br/>クラウドに自動バックアップ。</>}
      body="iCloud と連携することで、機種変更や端末紛失時も録音データを安全に守ります。複数の Apple デバイス間で、シームレスに同期されます。"
      bullets={[
        { t: 'iCloud 自動バックアップ対応', sub: '何もしなくても、録音が自動で保存されます' },
        { t: 'iPhone・iPad・Mac で共有', sub: 'どの端末からでも同じデータにアクセス' },
        { t: '通信量を抑える Wi-Fi のみ同期', sub: 'モバイルデータの使いすぎを防止' },
      ]}
      cta="準備完了 · 次へ"
      onNext={next}
    />
  );
}

Object.assign(window, { S1Welcome, S2Record, S3Transcribe, S4Summary, S5Privacy, S6UseCase, S7Cloud });
