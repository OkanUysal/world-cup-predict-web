import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/client';
import type { UserScore } from '../types';
import { useAuth } from '../context/AuthContext';

export default function LeaderboardPage() {
  const { user } = useAuth();
  const [scores, setScores] = useState<UserScore[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const data = await api.getLeaderboard();
      setScores(data ?? []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Yüklenemedi');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  return (
    <div className="page">
      {loading && (
        <div className="center-inline">
          <div className="spinner" />
        </div>
      )}

      {error && !loading && <div className="error-box">{error}</div>}

      {!loading && !error && scores.length === 0 && (
        <p className="empty">Henüz puan yok.</p>
      )}

      {!loading && scores.length > 0 && (
        <ol className="leaderboard">
          {scores.map((s, i) => (
            <li
              key={s.user_id}
              className={s.user_id === user?.id ? 'me' : ''}
            >
              <span className="rank">{i + 1}</span>
              <div className="leader-info">
                <strong>{s.user_name}</strong>
                <div className="leader-stats">
                  <span className="leader-stat-item" title="Tam Skor">
                    🎯 {s.exact_score_count ?? 0} Tam
                  </span>
                  <span className="leader-stat-item" title="Taraf Tahmini">
                    ⚽ {s.correct_outcome_count ?? 0} Taraf
                  </span>
                </div>
              </div>
              <span className="points">{s.total_points} puan</span>
            </li>
          ))}
        </ol>
      )}
    </div>
  );
}
