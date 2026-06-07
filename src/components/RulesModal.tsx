import { useEffect } from 'react';

interface Props {
  onClose: () => void;
}

export default function RulesModal({ onClose }: Props) {
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === 'Escape') onClose();
    }
    document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, [onClose]);

  return (
    <div
      className="modal-overlay"
      onClick={onClose}
      role="presentation"
    >
      <div
        className="modal rules-modal"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-labelledby="rules-title"
      >
        <div className="modal-header">
          <h2 id="rules-title">Puanlama Kuralları</h2>
          <button
            type="button"
            className="modal-close"
            onClick={onClose}
            aria-label="Kapat"
          >
            ✕
          </button>
        </div>

        <div className="modal-body rules-content">
          <p className="rules-intro">
            Toplam puan, kanaldaki tüm eventlerden kazandığın puanların
            toplamıdır.
          </p>

          <section>
            <h3>Maç skoru</h3>
            <p>Grup ve eleme maçları için skor tahmini yaparsın.</p>
            <ul>
              <li>
                <strong>3 puan</strong> — Tam skor doğru (ev–deplasman golleri
                birebir)
              </li>
              <li>
                <strong>1 puan</strong> — Skor yanlış ama sonuç doğru (kazanan
                veya beraberlik tutuyor)
              </li>
              <li>
                <strong>0 puan</strong> — Sonuç yanlış
              </li>
            </ul>
            <p className="rules-note">
              Tam skor tutarsa sadece 3 puan verilir; 1 puan eklenmez.
            </p>
            <p className="rules-note">
              Uzatmalar skora dahildir. Penaltı atışları skora yazılmaz — örn.
              normal + uzatma 1-1 biter, penaltıyla kazanan olsa bile resmi skor{' '}
              <strong>1-1</strong> sayılır.
            </p>
          </section>

          <section>
            <h3>Şampiyon</h3>
            <p>Turnuvayı kazanan takımı tahmin et.</p>
            <p>
              <strong>10 puan</strong> — Doğru · <strong>0 puan</strong> —
              Yanlış
            </p>
          </section>

          <section>
            <h3>İkinci</h3>
            <p>Finali kaybeden takımı tahmin et.</p>
            <p>
              <strong>5 puan</strong> — Doğru · <strong>0 puan</strong> —
              Yanlış
            </p>
          </section>

          <section>
            <h3>Üçüncü</h3>
            <p>3.’lük maçını kazanan takımı tahmin et.</p>
            <p>
              <strong>3 puan</strong> — Doğru · <strong>0 puan</strong> —
              Yanlış
            </p>
          </section>

          <table className="rules-table">
            <thead>
              <tr>
                <th>Event</th>
                <th>Doğru tahmin</th>
                <th>Puan</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Maç skoru</td>
                <td>Sonuç (kazanan/beraberlik)</td>
                <td>1</td>
              </tr>
              <tr>
                <td>Maç skoru</td>
                <td>Tam skor</td>
                <td>3</td>
              </tr>
              <tr>
                <td>Şampiyon</td>
                <td>Doğru takım</td>
                <td>10</td>
              </tr>
              <tr>
                <td>İkinci</td>
                <td>Doğru takım</td>
                <td>5</td>
              </tr>
              <tr>
                <td>Üçüncü</td>
                <td>Doğru takım</td>
                <td>3</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
