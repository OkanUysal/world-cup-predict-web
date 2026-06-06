import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../api/client';
import EventCard from '../components/EventCard';
import type { EventStatusFilter, EventWithPrediction } from '../types';

const TABS: { key: EventStatusFilter; label: string }[] = [
  { key: 'open', label: 'Açık' },
  { key: 'pending', label: 'Bekleyen' },
  { key: 'completed', label: 'Tamamlanan' },
];

export default function EventsPage() {
  const [status, setStatus] = useState<EventStatusFilter>('open');
  const [events, setEvents] = useState<EventWithPrediction[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [onlyWithoutPrediction, setOnlyWithoutPrediction] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const data = await api.getEvents(status);
      setEvents(data ?? []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Yüklenemedi');
      setEvents([]);
    } finally {
      setLoading(false);
    }
  }, [status]);

  useEffect(() => {
    load();
  }, [load]);

  const visibleEvents = useMemo(() => {
    if (!onlyWithoutPrediction) return events;
    return events.filter((item) => !item.my_prediction);
  }, [events, onlyWithoutPrediction]);

  return (
    <div className="page">
      <div className="tabs inline-tabs">
        {TABS.map((t) => (
          <button
            key={t.key}
            type="button"
            className={status === t.key ? 'active' : ''}
            onClick={() => setStatus(t.key)}
          >
            {t.label}
          </button>
        ))}
      </div>

      <label className="filter-checkbox">
        <input
          type="checkbox"
          checked={onlyWithoutPrediction}
          onChange={(e) => setOnlyWithoutPrediction(e.target.checked)}
        />
        Sadece tahmin yapmadığım eventleri göster
      </label>

      {loading && (
        <div className="center-inline">
          <div className="spinner" />
        </div>
      )}

      {error && !loading && <div className="error-box">{error}</div>}

      {!loading && !error && visibleEvents.length === 0 && (
        <p className="empty">
          {onlyWithoutPrediction
            ? 'Tahmin yapmadığınız event kalmadı.'
            : 'Bu kategoride event yok.'}
        </p>
      )}

      <div className="event-list">
        {visibleEvents.map((item) => (
          <EventCard
            key={item.event.id}
            item={item}
            onUpdated={load}
            linkToChannel={status !== 'open'}
          />
        ))}
      </div>
    </div>
  );
}
