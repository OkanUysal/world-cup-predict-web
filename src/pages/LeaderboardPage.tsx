import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/client';
import type { UserScore, UserPredictionResponse } from '../types';
import { useAuth } from '../context/AuthContext';
import { eventTypeLabel, formatChoice, formatResult, pointsClass } from '../utils/date';

interface ModalProps {
  selectedUser: UserScore;
  onClose: () => void;
}

function UserPredictionsModal({ selectedUser, onClose }: ModalProps) {
  const { user } = useAuth();
  const [predictions, setPredictions] = useState<UserPredictionResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadPredictions = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const data = await api.getUserPredictions(selectedUser.user_id);
      setPredictions(data ?? []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Yüklenemedi');
    } finally {
      setLoading(false);
    }
  }, [selectedUser.user_id]);

  useEffect(() => {
    loadPredictions();
  }, [loadPredictions]);

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === 'Escape') onClose();
    }
    document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, [onClose]);

  const isMe = selectedUser.user_id === user?.id;

  return (
    <div className="modal-overlay" onClick={onClose} role="presentation">
      <div
        className="modal prediction-modal"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-labelledby="modal-title"
      >
        <div className="modal-header">
          <h2 id="modal-title">
            {selectedUser.user_name} Tahminleri
          </h2>
          <button
            type="button"
            className="modal-close"
            onClick={onClose}
            aria-label="Kapat"
          >
            ✕
          </button>
        </div>

        <div className="modal-body prediction-modal-body">
          {loading && (
            <div className="center-inline">
              <div className="spinner" />
            </div>
          )}

          {error && !loading && <div className="error-box">{error}</div>}

          {!loading && !error && predictions.length === 0 && (
            <p className="empty">Tahmin bulunamadı.</p>
          )}

          {!loading && predictions.length > 0 && (
            <div className="modal-prediction-list">
              {predictions.map((p) => {
                const targetPred = p.target_prediction || (isMe ? p.my_prediction : undefined);
                const hasTargetPred = !!targetPred;

                return (
                  <div key={p.event.id} className="modal-prediction-item">
                    <div className="modal-prediction-event">
                      <div className="modal-event-meta">
                        <span className={`badge badge-${p.event.status}`}>
                          {p.event.status === 'open'
                            ? 'Açık'
                            : p.event.status === 'locked'
                            ? 'Kilitli'
                            : 'Tamamlandı'}
                        </span>
                        <span className="event-type">{eventTypeLabel(p.event.type)}</span>
                      </div>
                      <h4>{p.event.title}</h4>
                      {p.event.status === 'completed' && p.event.result && (
                        <div className="modal-event-result">
                          Sonuç: <strong>{formatResult(p.event.type, p.event.result)}</strong>
                        </div>
                      )}
                    </div>

                    <div className="modal-prediction-comparison">
                      <div className="comparison-col">
                        <span className="col-label">
                          {isMe ? 'Tahminim' : `${selectedUser.user_name}`}
                        </span>
                        <div
                          className={`col-val ${
                            p.event.status === 'completed' && hasTargetPred
                              ? pointsClass(targetPred.points_awarded)
                              : ''
                          }`}
                        >
                          {hasTargetPred
                            ? formatChoice(p.event.type, targetPred.choice)
                            : 'Tahmin yapmadı'}
                          {p.event.status === 'completed' && hasTargetPred && (
                            <span className="col-points">
                              {' '}
                              · {targetPred.points_awarded} puan
                            </span>
                          )}
                        </div>
                      </div>

                      {!isMe && (
                        <div className="comparison-col">
                          <span className="col-label">Benim Tahminim</span>
                          <div
                            className={`col-val ${
                              p.event.status === 'completed' && p.my_prediction
                                ? pointsClass(p.my_prediction.points_awarded)
                                : ''
                            }`}
                          >
                            {p.my_prediction
                              ? formatChoice(p.event.type, p.my_prediction.choice)
                              : 'Tahmin yapmadım'}
                            {p.event.status === 'completed' && p.my_prediction && (
                              <span className="col-points">
                                {' '}
                                · {p.my_prediction.points_awarded} puan
                              </span>
                            )}
                          </div>
                        </div>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default function LeaderboardPage() {
  const { user } = useAuth();
  const [scores, setScores] = useState<UserScore[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedUser, setSelectedUser] = useState<UserScore | null>(null);

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
              <button
                type="button"
                className="btn-detail"
                title="Tahmin Detayları"
                onClick={() => setSelectedUser(s)}
              >
                <svg
                  viewBox="0 0 24 24"
                  width="18"
                  height="18"
                  stroke="currentColor"
                  strokeWidth="2"
                  fill="none"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                  <circle cx="12" cy="12" r="3" />
                </svg>
              </button>
            </li>
          ))}
        </ol>
      )}

      {selectedUser && (
        <UserPredictionsModal
          selectedUser={selectedUser}
          onClose={() => setSelectedUser(null)}
        />
      )}
    </div>
  );
}
