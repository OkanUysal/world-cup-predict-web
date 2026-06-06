import { FormEvent, useCallback, useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { api } from '../api/client';
import type { EventDetailResponse, Prediction } from '../types';
import {
  eventTypeLabel,
  formatChoice,
  formatDate,
  statusLabel,
} from '../utils/date';

export default function EventDetailPage() {
  const { id } = useParams<{ id: string }>();
  const [detail, setDetail] = useState<EventDetailResponse | null>(null);
  const [channelPredictions, setChannelPredictions] = useState<Prediction[]>(
    [],
  );
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [submitError, setSubmitError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const [homeScore, setHomeScore] = useState('');
  const [awayScore, setAwayScore] = useState('');
  const [team, setTeam] = useState('');

  const load = useCallback(async () => {
    if (!id) return;
    setLoading(true);
    setError('');
    try {
      const data = await api.getEvent(id);
      setDetail(data);

      if (data.my_prediction) {
        const c = data.my_prediction.choice;
        if (data.event.type === 'match_score') {
          setHomeScore(String(c.home_score ?? ''));
          setAwayScore(String(c.away_score ?? ''));
        } else {
          setTeam(String(c.team ?? ''));
        }
      }

      if (data.event.status !== 'open') {
        try {
          const preds = await api.getEventPredictions(id);
          setChannelPredictions(preds ?? []);
        } catch {
          setChannelPredictions([]);
        }
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Yüklenemedi');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (!id || !detail) return;
    setSubmitError('');
    setSubmitting(true);

    try {
      let choice: Record<string, unknown>;
      if (detail.event.type === 'match_score') {
        choice = {
          home_score: parseInt(homeScore, 10),
          away_score: parseInt(awayScore, 10),
        };
      } else {
        choice = { team: team.trim() };
      }
      await api.submitPrediction(id, choice);
      await load();
    } catch (err) {
      setSubmitError(err instanceof Error ? err.message : 'Kaydedilemedi');
    } finally {
      setSubmitting(false);
    }
  }

  if (loading) {
    return (
      <div className="center-page">
        <div className="spinner" />
      </div>
    );
  }

  if (error || !detail) {
    return (
      <div className="page">
        <Link to="/events" className="back-link">
          ← Geri
        </Link>
        <div className="error-box">{error || 'Event bulunamadı'}</div>
      </div>
    );
  }

  const { event, my_prediction } = detail;
  const meta = event.metadata;
  const teams = Array.isArray(meta.teams) ? (meta.teams as string[]) : [];
  const canPredict = event.status === 'open';

  return (
    <div className="page">
      <Link to="/events" className="back-link">
        ← Geri
      </Link>

      <header className="page-header">
        <span className={`badge badge-${event.status}`}>
          {statusLabel(event.status)}
        </span>
        <h1>{event.title}</h1>
        <p className="muted">{eventTypeLabel(event.type)}</p>
        <p className="deadline">Son tarih: {formatDate(event.deadline)}</p>
      </header>

      {event.type === 'match_score' && (
        <div className="match-info card">
          <p>
            <strong>{String(meta.home_team)}</strong> vs{' '}
            <strong>{String(meta.away_team)}</strong>
          </p>
          {meta.kickoff_gmt && (
            <p className="muted">Başlangıç: {formatDate(String(meta.kickoff_gmt))}</p>
          )}
        </div>
      )}

      {my_prediction && (
        <div className="card highlight">
          <strong>Tahminin:</strong>{' '}
          {formatChoice(event.type, my_prediction.choice)}
          {event.status === 'completed' && (
            <span> · {my_prediction.points_awarded} puan</span>
          )}
        </div>
      )}

      {canPredict && (
        <form className="card prediction-form" onSubmit={handleSubmit}>
          <h2>{my_prediction ? 'Tahmini Güncelle' : 'Tahmin Gir'}</h2>
          {submitError && <div className="error-box">{submitError}</div>}

          {event.type === 'match_score' ? (
            <div className="score-row">
              <label>
                {String(meta.home_team)}
                <input
                  type="number"
                  min={0}
                  value={homeScore}
                  onChange={(e) => setHomeScore(e.target.value)}
                  required
                />
              </label>
              <span className="score-sep">-</span>
              <label>
                {String(meta.away_team)}
                <input
                  type="number"
                  min={0}
                  value={awayScore}
                  onChange={(e) => setAwayScore(e.target.value)}
                  required
                />
              </label>
            </div>
          ) : (
            <label>
              Takım seç
              <select
                value={team}
                onChange={(e) => setTeam(e.target.value)}
                required
              >
                <option value="">Seçin…</option>
                {teams.map((t) => (
                  <option key={t} value={t}>
                    {t}
                  </option>
                ))}
              </select>
            </label>
          )}

          <button type="submit" className="btn-primary" disabled={submitting}>
            {submitting ? 'Kaydediliyor…' : 'Kaydet'}
          </button>
        </form>
      )}

      {channelPredictions.length > 0 && (
        <div className="card">
          <h2>Kanal Tahminleri</h2>
          <ul className="prediction-list">
            {channelPredictions.map((p) => (
              <li key={p.id}>
                <span className="user-name">{p.user_name ?? 'Kullanıcı'}</span>
                <span>{formatChoice(event.type, p.choice)}</span>
                {event.status === 'completed' && (
                  <span className="points">{p.points_awarded} p</span>
                )}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
