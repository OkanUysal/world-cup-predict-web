import { Link } from 'react-router-dom';
import type { EventWithPrediction } from '../types';
import { eventTypeLabel, formatChoice, formatDate, statusLabel } from '../utils/date';

interface Props {
  item: EventWithPrediction;
}

export default function EventCard({ item }: Props) {
  const { event, my_prediction } = item;
  const meta = event.metadata;

  let subtitle = eventTypeLabel(event.type);
  if (event.type === 'match_score') {
    subtitle = `${meta.home_team} vs ${meta.away_team}`;
  }

  return (
    <Link to={`/events/${event.id}`} className="event-card">
      <div className="event-card-header">
        <span className={`badge badge-${event.status}`}>{statusLabel(event.status)}</span>
        <span className="event-type">{eventTypeLabel(event.type)}</span>
      </div>
      <h3>{event.title}</h3>
      {event.type === 'match_score' && (
        <p className="muted">{subtitle}</p>
      )}
      <p className="deadline">Son tarih: {formatDate(event.deadline)}</p>
      {my_prediction && (
        <p className="my-prediction">
          Tahminin: {formatChoice(event.type, my_prediction.choice)}
          {event.status === 'completed' && (
            <span className="points"> · {my_prediction.points_awarded} puan</span>
          )}
        </p>
      )}
      {!my_prediction && event.status === 'open' && (
        <p className="hint">Tahmin gir →</p>
      )}
    </Link>
  );
}
