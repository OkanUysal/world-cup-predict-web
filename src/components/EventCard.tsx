import { FormEvent, useEffect, useState } from 'react';
import { api } from '../api/client';
import type { EventWithPrediction, Prediction } from '../types';
import {
  eventTypeLabel,
  formatChoice,
  formatDate,
  statusLabel,
} from '../utils/date';

interface Props {
  item: EventWithPrediction;
  onUpdated: () => void;
}

export default function EventCard({ item, onUpdated }: Props) {
  const { event, my_prediction } = item;
  const meta = event.metadata;
  const teams = Array.isArray(meta.teams) ? (meta.teams as string[]) : [];
  const canPredict = event.status === 'open';

  const [homeScore, setHomeScore] = useState('');
  const [awayScore, setAwayScore] = useState('');
  const [team, setTeam] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');
  const [savedMsg, setSavedMsg] = useState('');
  const [channelPredictions, setChannelPredictions] = useState<Prediction[]>(
    [],
  );
  const [loadingChannel, setLoadingChannel] = useState(false);

  useEffect(() => {
    if (my_prediction) {
      const c = my_prediction.choice;
      if (event.type === 'match_score') {
        setHomeScore(String(c.home_score ?? ''));
        setAwayScore(String(c.away_score ?? ''));
      } else {
        setTeam(String(c.team ?? ''));
      }
    } else {
      setHomeScore('');
      setAwayScore('');
      setTeam('');
    }
    setSubmitError('');
    setSavedMsg('');
  }, [item]);

  useEffect(() => {
    if (event.status === 'open') {
      setChannelPredictions([]);
      return;
    }
    setLoadingChannel(true);
    api
      .getEventPredictions(event.id)
      .then((data) => setChannelPredictions(data ?? []))
      .catch(() => setChannelPredictions([]))
      .finally(() => setLoadingChannel(false));
  }, [event.id, event.status]);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setSubmitError('');
    setSavedMsg('');
    setSubmitting(true);

    try {
      let choice: Record<string, unknown>;
      if (event.type === 'match_score') {
        choice = {
          home_score: parseInt(homeScore, 10),
          away_score: parseInt(awayScore, 10),
        };
      } else {
        choice = { team: team.trim() };
      }
      await api.submitPrediction(event.id, choice);
      setSavedMsg('Kaydedildi ✓');
      onUpdated();
    } catch (err) {
      setSubmitError(err instanceof Error ? err.message : 'Kaydedilemedi');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <article className="event-card">
      <div className="event-card-header">
        <span className={`badge badge-${event.status}`}>
          {statusLabel(event.status)}
        </span>
        <span className="event-type">{eventTypeLabel(event.type)}</span>
      </div>

      <h3>{event.title}</h3>

      {event.type === 'match_score' && (
        <p className="muted match-label">
          {String(meta.home_team)} vs {String(meta.away_team)}
        </p>
      )}

      <p className="deadline">Son tarih: {formatDate(event.deadline)}</p>

      {canPredict && (
        <form className="inline-prediction" onSubmit={handleSubmit}>
          {event.type === 'match_score' ? (
            <div className="score-row compact">
              <label>
                <span className="score-team">{String(meta.home_team)}</span>
                <input
                  type="number"
                  min={0}
                  max={99}
                  inputMode="numeric"
                  value={homeScore}
                  onChange={(e) => setHomeScore(e.target.value)}
                  required
                  placeholder="0"
                />
              </label>
              <span className="score-sep">-</span>
              <label>
                <span className="score-team">{String(meta.away_team)}</span>
                <input
                  type="number"
                  min={0}
                  max={99}
                  inputMode="numeric"
                  value={awayScore}
                  onChange={(e) => setAwayScore(e.target.value)}
                  required
                  placeholder="0"
                />
              </label>
            </div>
          ) : (
            <label className="team-select">
              <span className="score-team">Takım</span>
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

          {submitError && (
            <p className="inline-error">{submitError}</p>
          )}
          {savedMsg && <p className="inline-success">{savedMsg}</p>}

          <button
            type="submit"
            className="btn-save"
            disabled={submitting}
          >
            {submitting
              ? 'Kaydediliyor…'
              : my_prediction
                ? 'Güncelle'
                : 'Kaydet'}
          </button>
        </form>
      )}

      {!canPredict && my_prediction && (
        <p className="my-prediction">
          Tahminin: {formatChoice(event.type, my_prediction.choice)}
          {event.status === 'completed' && (
            <span className="points">
              {' '}
              · {my_prediction.points_awarded} puan
            </span>
          )}
        </p>
      )}

      {!canPredict && (
        <div className="channel-predictions">
          <p className="channel-title">Kanal tahminleri</p>
          {loadingChannel && (
            <p className="muted small">Yükleniyor…</p>
          )}
          {!loadingChannel && channelPredictions.length === 0 && (
            <p className="muted small">Henüz tahmin yok.</p>
          )}
          {!loadingChannel && channelPredictions.length > 0 && (
            <ul className="prediction-list compact">
              {channelPredictions.map((p) => (
                <li key={p.id}>
                  <span className="user-name">
                    {p.user_name ?? 'Kullanıcı'}
                  </span>
                  <span>{formatChoice(event.type, p.choice)}</span>
                  {event.status === 'completed' && (
                    <span className="points">{p.points_awarded}p</span>
                  )}
                </li>
              ))}
            </ul>
          )}
        </div>
      )}
    </article>
  );
}
