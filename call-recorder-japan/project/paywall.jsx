// Long-form scrollable paywall — Japan style.
// Sections (top → bottom):
//   1. Hero crown + 5-star rating + headline
//   2. Numbered benefit cards (4) with mini mockups
//   3. Free vs Premium comparison table (○/×)
//   4. Plan selection (週間 / 月間) with savings badge
//   5. Testimonials (3 cards, real-people style)
//   6. Security badges row
//   7. FAQ accordion (5 questions)
//   8. Final CTA + restore + tiny legal print

function Paywall({ onClose, onUpgrade }) {
  const [plan, setPlan] = React.useState('monthly'); // weekly | monthly
  const [openFaq, setOpenFaq] = React.useState(0);

  const benefits = [
    {
      n: '01',
      tag: '無制限の録音',
      h: '回数・時間の制限なし',
      b: '無料版は1日3回・5分まで。プレミアムなら、何時間でも何件でも保存できます。',
      icon: '∞',
    },
    {
      n: '02',
      tag: 'AI 文字起こし',
      h: '全ての通話を自動でテキスト化',
      b: '日本語に最適化された高精度モデル。話者識別・専門用語にも対応します。',
      icon: '📝',
    },
    {
      n: '03',
      tag: 'AI 要約 & タスク抽出',
      h: '長い通話を3行のサマリーに',
      b: '決定事項・アクション項目を自動で抜き出し。会議後の議事録作成がゼロに。',
      icon: '✨',
    },
    {
      n: '04',
      tag: 'クラウド & エクスポート',
      h: '無制限のクラウド保存・書き出し',
      b: 'iCloud 自動バックアップ。MP3・PDF・テキスト・字幕ファイル形式で書き出し可能。',
      icon: '☁︎',
    },
  ];

  const features = [
    ['録音時間', '1日 5分まで', '無制限'],
    ['録音回数', '1日 3件まで', '無制限'],
    ['音質', '標準音質', '高音質 (320kbps)'],
    ['AI 文字起こし', false, true],
    ['AI 要約 & タスク抽出', false, true],
    ['全文検索', false, true],
    ['クラウドバックアップ', false, true],
    ['MP3 / PDF 書き出し', false, true],
    ['広告表示', 'あり', 'なし'],
    ['優先サポート', false, true],
  ];

  const reviews = [
    {
      name: '田中 健一',
      meta: '営業職 · 36歳 · 東京',
      stars: 5,
      title: '商談の議事録作成が10分の1に',
      body: 'お客様との会話を逃さず記録できるので、上司への共有もスムーズ。要約機能のおかげで議事録作成の時間が劇的に減りました。',
      avatar: '#4a6b8a',
    },
    {
      name: '佐藤 美咲',
      meta: 'ライター · 29歳 · 大阪',
      stars: 5,
      title: 'インタビューの文字起こしが圧倒的に早い',
      body: '取材音声を自動でテキスト化してくれるので、執筆に集中できるようになりました。日本語の精度がとにかく高い。',
      avatar: '#a87a5a',
    },
    {
      name: '山本 大輔',
      meta: '個人事業主 · 42歳 · 福岡',
      stars: 5,
      title: '安心して大切な約束を記録',
      body: '口約束で済むことが多い業界ですが、録音とテキストで残せるので安心。プライバシー設計もしっかりしていて信頼できます。',
      avatar: '#6a8a5a',
    },
  ];

  const faqs = [
    {
      q: '無料トライアルはありますか？',
      a: 'はい。初回登録の方は3日間すべての機能を無料でお試しいただけます。期間中はいつでもキャンセル可能で、料金は発生しません。',
    },
    {
      q: '解約はいつでもできますか？',
      a: '可能です。設定 > Apple ID > サブスクリプションからワンタップで解約できます。残期間は引き続きご利用いただけます。',
    },
    {
      q: '録音データは安全に管理されますか？',
      a: 'すべての録音とテキストは AES-256 で暗号化され、お客様の許可なく第三者に共有されることはありません。退会時は30日以内に完全削除されます。',
    },
    {
      q: '機種変更してもデータは引き継げますか？',
      a: '同じ Apple ID でログインすれば、iCloud 経由ですべての録音・テキストが自動的に復元されます。',
    },
    {
      q: '通話相手にも録音は通知されますか？',
      a: '通知音は再生されません。録音時の通知については各国・各地域の法令を遵守してご利用ください。',
    },
  ];

  return (
    <div className="screen-key" style={{
      height: '100%', display: 'flex', flexDirection: 'column',
      background: '#07090a',
    }}>
      {/* Close button overlay */}
      <button onClick={onClose} style={{
        position: 'absolute', top: 56, right: 16, zIndex: 30,
        width: 32, height: 32, borderRadius: 999,
        background: 'rgba(255,255,255,0.08)', border: 'none',
        color: 'var(--ink-2)', fontSize: 16, cursor: 'pointer',
        display: 'grid', placeItems: 'center',
      }}>✕</button>

      <div className="phone-scroll" style={{ flex: 1, overflow: 'auto', paddingTop: 58 }}>
        {/* ── Hero ── */}
        <div style={{
          position: 'relative', padding: '36px 22px 24px',
          background: 'radial-gradient(circle at 50% 0%, rgba(31,224,122,0.18), transparent 70%)',
          textAlign: 'center',
        }}>
          {/* Crown badge */}
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            padding: '6px 12px', borderRadius: 999,
            background: 'linear-gradient(135deg, #ffd76b, #f59e0b)',
            color: '#3a2806', fontSize: 11, fontWeight: 800,
            marginBottom: 16, boxShadow: '0 6px 16px rgba(245,158,11,0.3)',
          }}>
            <span>👑</span> PREMIUM プラン
          </div>
          <h1 style={{
            fontSize: 26, lineHeight: 1.3, fontWeight: 900, margin: '0 0 12px',
            letterSpacing: '-0.01em',
          }}>
            すべての機能を、<br/>
            <span style={{ color: 'var(--accent)' }}>無制限で。</span>
          </h1>
          <p className="ja-body" style={{ maxWidth: 280, margin: '0 auto' }}>
            録音・文字起こし・要約・検索 — プロフェッショナルが必要とする全機能を、ひとつのアプリで。
          </p>
          {/* Stars */}
          <div style={{
            marginTop: 18, display: 'inline-flex', alignItems: 'center', gap: 8,
            padding: '8px 14px', borderRadius: 999,
            background: 'rgba(255,255,255,0.04)', border: '1px solid var(--line)',
          }}>
            <span style={{ color: '#ffc736', fontSize: 13 }}>★★★★★</span>
            <span style={{ fontSize: 12, color: 'var(--ink-2)' }}>
              <b style={{ color: 'var(--ink)' }}>4.8</b> · 12,400件のレビュー
            </span>
          </div>
        </div>

        {/* ── Numbered benefit cards ── */}
        <div style={{ padding: '12px 22px 8px' }}>
          <div style={{
            fontSize: 11, letterSpacing: '0.1em', fontWeight: 700,
            color: 'var(--ink-3)', textTransform: 'uppercase', marginBottom: 12,
          }}>
            ⎯⎯ プレミアムでできること
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {benefits.map((b) => (
              <div key={b.n} style={{
                padding: 14, borderRadius: 14,
                background: 'var(--card)', border: '1px solid var(--line)',
                display: 'flex', gap: 12, alignItems: 'flex-start',
              }}>
                <div style={{ flex: 'none' }}>
                  <div style={{
                    fontSize: 10, fontWeight: 800, color: 'var(--accent)', letterSpacing: '0.08em',
                  }}>{b.n}</div>
                  <div style={{
                    width: 40, height: 40, borderRadius: 10, marginTop: 6,
                    background: 'rgba(31,224,122,0.10)', border: '1px solid rgba(31,224,122,0.25)',
                    display: 'grid', placeItems: 'center', fontSize: 20, color: 'var(--accent)',
                  }}>{b.icon}</div>
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{
                    fontSize: 10.5, color: 'var(--accent)', fontWeight: 700, letterSpacing: '0.04em',
                    textTransform: 'uppercase', marginBottom: 2,
                  }}>{b.tag}</div>
                  <div style={{ fontSize: 14.5, fontWeight: 700, lineHeight: 1.4, color: 'var(--ink)', marginBottom: 4 }}>
                    {b.h}
                  </div>
                  <div style={{ fontSize: 12, color: 'var(--ink-2)', lineHeight: 1.6 }}>
                    {b.b}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* ── Comparison table ── */}
        <div style={{ padding: '22px 22px 8px' }}>
          <div style={{
            fontSize: 11, letterSpacing: '0.1em', fontWeight: 700,
            color: 'var(--ink-3)', textTransform: 'uppercase', marginBottom: 12,
          }}>
            ⎯⎯ 無料版とプレミアムの違い
          </div>
          <table className="compare">
            <thead>
              <tr>
                <th>機能</th>
                <th className="col-free">無料</th>
                <th className="col-pro pro">PRO</th>
              </tr>
            </thead>
            <tbody>
              {features.map(([name, free, pro], i) => (
                <tr key={i}>
                  <th>{name}</th>
                  <td className="col-free">
                    {typeof free === 'boolean'
                      ? <span className={free ? 'yes' : 'no'}>{free ? '○' : '×'}</span>
                      : <span style={{ fontSize: 11, color: 'var(--ink-2)' }}>{free}</span>}
                  </td>
                  <td className="col-pro">
                    {typeof pro === 'boolean'
                      ? <span className={pro ? 'yes' : 'no'}>{pro ? '○' : '×'}</span>
                      : <span style={{ fontSize: 11, color: 'var(--accent)', fontWeight: 600 }}>{pro}</span>}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* ── Plan selector ── */}
        <div style={{ padding: '24px 22px 8px' }}>
          <div style={{
            fontSize: 11, letterSpacing: '0.1em', fontWeight: 700,
            color: 'var(--ink-3)', textTransform: 'uppercase', marginBottom: 12,
          }}>
            ⎯⎯ プランを選ぶ
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {/* Monthly (recommended) */}
            <button onClick={() => setPlan('monthly')}
              style={{
                position: 'relative', padding: '16px 16px', borderRadius: 16,
                background: plan === 'monthly' ? 'rgba(31,224,122,0.08)' : 'var(--card)',
                border: plan === 'monthly' ? '1.5px solid var(--accent)' : '1px solid var(--line)',
                color: 'var(--ink)', textAlign: 'left', cursor: 'pointer',
                fontFamily: 'inherit', display: 'flex', alignItems: 'center', gap: 12,
              }}>
              <div style={{
                position: 'absolute', top: -10, right: 14, padding: '4px 10px', borderRadius: 999,
                background: 'var(--accent)', color: 'var(--accent-ink)', fontSize: 10, fontWeight: 800,
                letterSpacing: '0.04em',
              }}>おすすめ · 50% お得</div>
              <div style={{
                width: 22, height: 22, borderRadius: 999, flex: 'none',
                border: plan === 'monthly' ? 'none' : '1.5px solid rgba(255,255,255,0.2)',
                background: plan === 'monthly' ? 'var(--accent)' : 'transparent',
                color: 'var(--accent-ink)', display: 'grid', placeItems: 'center', fontSize: 12, fontWeight: 900,
              }}>{plan === 'monthly' ? '✓' : ''}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 800 }}>月間プラン</div>
                <div style={{ fontSize: 11.5, color: 'var(--ink-2)', marginTop: 2 }}>
                  3日間無料 · その後 $14.99 / 月
                </div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: 18, fontWeight: 900, color: 'var(--accent)' }}>$14.99</div>
                <div style={{ fontSize: 10, color: 'var(--ink-3)', marginTop: 2 }}>約 $3.46 / 週</div>
              </div>
            </button>
            {/* Weekly */}
            <button onClick={() => setPlan('weekly')}
              style={{
                padding: '16px 16px', borderRadius: 16,
                background: plan === 'weekly' ? 'rgba(31,224,122,0.08)' : 'var(--card)',
                border: plan === 'weekly' ? '1.5px solid var(--accent)' : '1px solid var(--line)',
                color: 'var(--ink)', textAlign: 'left', cursor: 'pointer',
                fontFamily: 'inherit', display: 'flex', alignItems: 'center', gap: 12,
              }}>
              <div style={{
                width: 22, height: 22, borderRadius: 999, flex: 'none',
                border: plan === 'weekly' ? 'none' : '1.5px solid rgba(255,255,255,0.2)',
                background: plan === 'weekly' ? 'var(--accent)' : 'transparent',
                color: 'var(--accent-ink)', display: 'grid', placeItems: 'center', fontSize: 12, fontWeight: 900,
              }}>{plan === 'weekly' ? '✓' : ''}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 800 }}>週間プラン</div>
                <div style={{ fontSize: 11.5, color: 'var(--ink-2)', marginTop: 2 }}>
                  $6.99 / 週から
                </div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: 18, fontWeight: 900, color: 'var(--ink)' }}>$6.99</div>
                <div style={{ fontSize: 10, color: 'var(--ink-3)', marginTop: 2 }}>毎週請求</div>
              </div>
            </button>
          </div>

          {/* Reassurance row */}
          <div style={{
            marginTop: 14, padding: '10px 12px', borderRadius: 12,
            background: 'rgba(31,224,122,0.06)', border: '1px solid rgba(31,224,122,0.15)',
            display: 'flex', alignItems: 'center', gap: 10,
          }}>
            <div style={{
              width: 28, height: 28, borderRadius: 999, background: 'rgba(31,224,122,0.18)',
              display: 'grid', placeItems: 'center', flex: 'none', color: 'var(--accent)', fontSize: 14,
            }}>✓</div>
            <div style={{ fontSize: 11.5, color: 'var(--ink-2)', lineHeight: 1.5 }}>
              <b style={{ color: 'var(--ink)' }}>3日間の無料トライアル付き。</b><br/>
              期間中はいつでもキャンセル可能・料金発生なし。
            </div>
          </div>
        </div>

        {/* ── Testimonials ── */}
        <div style={{ padding: '24px 22px 8px' }}>
          <div style={{
            fontSize: 11, letterSpacing: '0.1em', fontWeight: 700,
            color: 'var(--ink-3)', textTransform: 'uppercase', marginBottom: 12,
          }}>
            ⎯⎯ ユーザーの声
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {reviews.map((r, i) => (
              <div key={i} style={{
                padding: 14, borderRadius: 14,
                background: 'var(--card)', border: '1px solid var(--line)',
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 8 }}>
                  <div style={{
                    width: 36, height: 36, borderRadius: 999,
                    background: `linear-gradient(135deg, ${r.avatar}, ${r.avatar}88)`,
                    display: 'grid', placeItems: 'center', color: 'rgba(255,255,255,0.8)',
                    fontSize: 14, fontWeight: 700, flex: 'none',
                  }}>{r.name[0]}</div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 12.5, fontWeight: 700 }}>{r.name}</div>
                    <div style={{ fontSize: 10.5, color: 'var(--ink-3)', marginTop: 1 }}>{r.meta}</div>
                  </div>
                  <div style={{ color: '#ffc736', fontSize: 11 }}>{'★'.repeat(r.stars)}</div>
                </div>
                <div style={{ fontSize: 13, fontWeight: 700, lineHeight: 1.4, marginBottom: 4 }}>
                  「{r.title}」
                </div>
                <div style={{ fontSize: 12, color: 'var(--ink-2)', lineHeight: 1.65 }}>
                  {r.body}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* ── Security badges ── */}
        <div style={{ padding: '24px 22px 8px' }}>
          <div style={{
            display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 8,
          }}>
            {[
              { i: '🔒', t: 'AES-256 暗号化', s: '通信・保存ともに保護' },
              { i: '☁︎', t: 'iCloud 自動同期', s: 'Apple の安全基準で運用' },
              { i: '🚫', t: '広告・追跡なし', s: 'データを第三者に販売しません' },
              { i: '🗑', t: 'いつでも完全削除', s: '退会時は30日以内に消去' },
            ].map((b, i) => (
              <div key={i} style={{
                padding: 12, borderRadius: 12,
                background: 'var(--card)', border: '1px solid var(--line)',
                display: 'flex', flexDirection: 'column', gap: 4,
              }}>
                <div style={{ fontSize: 16, marginBottom: 2 }}>{b.i}</div>
                <div style={{ fontSize: 11.5, fontWeight: 700 }}>{b.t}</div>
                <div style={{ fontSize: 10, color: 'var(--ink-3)', lineHeight: 1.5 }}>{b.s}</div>
              </div>
            ))}
          </div>
        </div>

        {/* ── FAQ ── */}
        <div style={{ padding: '24px 22px 8px' }}>
          <div style={{
            fontSize: 11, letterSpacing: '0.1em', fontWeight: 700,
            color: 'var(--ink-3)', textTransform: 'uppercase', marginBottom: 12,
          }}>
            ⎯⎯ よくある質問
          </div>
          <div className="faq">
            {faqs.map((f, i) => (
              <div key={i} className={`faq-item ${openFaq === i ? 'open' : ''}`}>
                <button className="faq-q" onClick={() => setOpenFaq(openFaq === i ? -1 : i)}>
                  <span>Q. {f.q}</span>
                  <span className="chev">▼</span>
                </button>
                <div className="faq-a">A. {f.a}</div>
              </div>
            ))}
          </div>
        </div>

        {/* ── Bottom legal ── */}
        <div style={{ padding: '20px 22px 24px', textAlign: 'center' }}>
          <div style={{ fontSize: 10, color: 'var(--ink-3)', lineHeight: 1.7 }}>
            自動更新サブスクリプション。期間終了の24時間前までに解約されない限り、自動的に更新されます。<br/>
            <span style={{ color: 'var(--ink-2)' }}>利用規約</span> · <span style={{ color: 'var(--ink-2)' }}>プライバシーポリシー</span>
          </div>
        </div>

        <div style={{ height: 140 }} />
      </div>

      {/* ── Fixed bottom CTA ── */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0,
        padding: '14px 22px 32px',
        background: 'linear-gradient(180deg, rgba(7,9,10,0) 0%, rgba(7,9,10,0.95) 32%, #07090a 70%)',
        zIndex: 20,
      }}>
        <button className="cta" onClick={onUpgrade}>
          3日間無料で始める <span style={{ marginLeft: 4 }}>→</span>
        </button>
        <div style={{
          marginTop: 8, display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        }}>
          <button onClick={onClose} style={{
            background: 'none', border: 'none', color: 'var(--ink-3)',
            fontSize: 11.5, cursor: 'pointer', fontFamily: 'inherit',
          }}>あとで決める</button>
          <button style={{
            background: 'none', border: 'none', color: 'var(--ink-3)',
            fontSize: 11.5, cursor: 'pointer', fontFamily: 'inherit',
          }}>購入を復元</button>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { Paywall });
