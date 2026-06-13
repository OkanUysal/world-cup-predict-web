import { useCallback, useEffect, useState } from 'react';
import { Link, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../api/client';
import type { EventDetailResponse, Prediction } from '../types';
import {
  eventTypeLabel,
  formatChoice,
  formatDate,
  formatResult,
  pointsClass,
  statusLabel,
} from '../utils/date';
import { eventsListPath, parseEventStatus } from '../utils/eventsNav';

export default function EventChannelPage() {
  const { id } = useParams<{ id: string }>();
  const [searchParams] = useSearchParams();
  const listStatus = parseEventStatus(searchParams.get('status'));
  const backTo = eventsListPath(listStatus);
  const [detail, setDetail] = useState<EventDetailResponse | null>(null);
  const [predictions, setPredictions] = useState<Prediction[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = useCallback(async () => {
    if (!id) return;
    setLoading(true);
    setError('');
    try {
      const [eventData, preds] = await Promise.all([
        api.getEvent(id),
        api.getEventPredictions(id),
      ]);
      setDetail(eventData);
      setPredictions(preds ?? []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Yüklenemedi');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

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
        <Link to={backTo} className="back-link">
          ← Geri
        </Link>
        <div className="error-box">{error || 'Event bulunamadı'}</div>
      </div>
    );
  }

  const { event, my_prediction } = detail;
  const meta = event.metadata;
  const isCompleted = event.status === 'completed';

  return (
    <div className="page">
      <Link to={backTo} className="back-link">
        ← Geri
      </Link>

      <header className="page-header">
        <span className={`badge badge-${event.status}`}>
          {statusLabel(event.status)}
        </span>
        <h1>{event.title}</h1>
        <p className="muted">{eventTypeLabel(event.type)}</p>
        {event.type === 'match_score' && (
          <p className="muted">
            {String(meta.home_team)} vs {String(meta.away_team)}
          </p>
        )}
        <p className="deadline">Son tarih: {formatDate(event.deadline)}</p>
      </header>

      {isCompleted && event.result && (
        <div className="card event-result-card">
          <strong>Sonuç:</strong>{' '}
          {formatResult(event.type, event.result)}
        </div>
      )}

      {my_prediction && (
        <div
          className={`card ${
            isCompleted ? pointsClass(my_prediction.points_awarded) + '-bg' : 'highlight'
          }`}
        >
          <p
            className={
              isCompleted ? pointsClass(my_prediction.points_awarded) : ''
            }
          >
            <strong>Tahminin:</strong>{' '}
            {formatChoice(event.type, my_prediction.choice)}
            {isCompleted && (
              <span className="points-label">
                {' '}
                · {my_prediction.points_awarded} puan
              </span>
            )}
          </p>
        </div>
      )}

      <div className="card">
        <h2 className="section-title">Kanal Tahminleri</h2>
        {predictions.length === 0 ? (
          <p className="muted">Henüz tahmin yok.</p>
        ) : (
          <ul className="prediction-list">
            {predictions.map((p) => (
              <li key={p.id}>
                <span className="user-name">{p.user_name ?? 'Kullanıcı'}</span>
                <span>{formatChoice(event.type, p.choice)}</span>
                {isCompleted && (
                  <span
                    className={`points-badge ${pointsClass(p.points_awarded)}`}
                  >
                    {p.points_awarded} p
                  </span>
                )}
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
