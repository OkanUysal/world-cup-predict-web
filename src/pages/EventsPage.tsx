import { useCallback, useEffect, useState } from 'react';
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

  return (
    <div className="page">
      <header className="page-header">
        <h1>Tahminler</h1>
      </header>

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

      {loading && (
        <div className="center-inline">
          <div className="spinner" />
        </div>
      )}

      {error && !loading && <div className="error-box">{error}</div>}

      {!loading && !error && events.length === 0 && (
        <p className="empty">Bu kategoride event yok.</p>
      )}

      <div className="event-list">
        {events.map((item) => (
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
