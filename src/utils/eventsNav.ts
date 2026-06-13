import type { EventStatusFilter } from '../types';

export function parseEventStatus(
  value: string | null,
): EventStatusFilter {
  if (value === 'pending' || value === 'completed') return value;
  return 'open';
}

export function eventsListPath(status: EventStatusFilter): string {
  if (status === 'open') return '/events';
  return `/events?status=${status}`;
}

export function channelPath(eventId: string, status: EventStatusFilter): string {
  const base = `/events/${eventId}/channel`;
  if (status === 'open') return base;
  return `${base}?status=${status}`;
}
