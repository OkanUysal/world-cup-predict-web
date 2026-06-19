import { FormEvent, useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../api/client';
import {
  countdownUrgency,
  formatCountdown,
  useCountdown,
} from '../hooks/useCountdown';
import type { EventStatusFilter, EventWithPrediction } from '../types';
import { channelPath } from '../utils/eventsNav';
import {
  eventTypeLabel,
  formatChoice,
  formatDeadline,
  formatResult,
  pointsClass,
  statusLabel,
} from '../utils/date';

interface Props {
  item: EventWithPrediction;
  onUpdated: () => void;
  linkToChannel?: boolean;
  listStatus?: EventStatusFilter;
}

export default function EventCard({
  item,
  onUpdated,
  linkToChannel = false,
  listStatus = 'open',
}: Props) {
  const { event, my_prediction } = item;
  const meta = event.metadata;
  const teams = Array.isArray(meta.teams) ? (meta.teams as string[]) : [];
  const canPredict = event.status === 'open';
  const isCompleted = event.status === 'completed';
  const remaining = useCountdown(event.deadline, canPredict);

  const [homeScore, setHomeScore] = useState('');
  const [awayScore, setAwayScore] = useState('');
  const [team, setTeam] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');
  const [savedMsg, setSavedMsg] = useState('');

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

  const body = (
    <>
      <div className="event-card-header">
        <div className="event-card-meta">
          <span className={`badge badge-${event.status}`}>
            {statusLabel(event.status)}
          </span>
          <span className="event-type">{eventTypeLabel(event.type)}</span>
        </div>
        {canPredict && (
          <span
            className={`countdown-badge ${countdownUrgency(remaining)}`}
            title={formatDeadline(event.deadline, {
              eventType: event.type,
              label: canPredict ? 'bitis' : 'son_tarih',
            })}
          >
            {formatCountdown(remaining)}
          </span>
        )}
      </div>

      <h3>{event.title}</h3>

      {event.type === 'match_score' && (
        <p className="muted match-label">
          {String(meta.home_team)} vs {String(meta.away_team)}
        </p>
      )}

      <p className="deadline muted">
        {formatDeadline(event.deadline, {
          eventType: event.type,
          label: canPredict ? 'bitis' : 'son_tarih',
        })}
      </p>

      {isCompleted && event.result && (
        <p className="event-result">
          <strong>Sonuç:</strong>{' '}
          {formatResult(event.type, event.result)}
        </p>
      )}

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

          {submitError && <p className="inline-error">{submitError}</p>}
          {savedMsg && <p className="inline-success">{savedMsg}</p>}

          <button type="submit" className="btn-save" disabled={submitting}>
            {submitting
              ? 'Kaydediliyor…'
              : my_prediction
                ? 'Güncelle'
                : 'Kaydet'}
          </button>
        </form>
      )}

      {!canPredict && my_prediction && (
        <p
          className={`my-prediction ${
            isCompleted ? pointsClass(my_prediction.points_awarded) : ''
          }`}
        >
          Tahminin: {formatChoice(event.type, my_prediction.choice)}
          {isCompleted && (
            <span className="points-label">
              {' '}
              · {my_prediction.points_awarded} puan
            </span>
          )}
        </p>
      )}

      {!canPredict && !my_prediction && (
        <p className="muted small no-prediction">Tahmin girmedin</p>
      )}

      {linkToChannel && (
        <p className="card-hint">Kanal tahminleri →</p>
      )}
    </>
  );

  if (linkToChannel) {
    return (
      <Link
        to={channelPath(event.id, listStatus)}
        className="event-card event-card-link"
      >
        {body}
      </Link>
    );
  }

  return <article className="event-card">{body}</article>;
}
