import { useEffect, useState } from 'react';

export function getRemainingMs(deadline: string): number {
  return Math.max(0, new Date(deadline).getTime() - Date.now());
}

export function formatCountdown(ms: number): string {
  if (ms <= 0) return '0sn';

  const totalSec = Math.floor(ms / 1000);
  const days = Math.floor(totalSec / 86400);
  const hours = Math.floor((totalSec % 86400) / 3600);
  const mins = Math.floor((totalSec % 3600) / 60);
  const secs = totalSec % 60;

  if (days > 0) {
    return `${days}g ${hours}s`;
  }
  if (hours > 0) {
    return `${hours}s ${String(mins).padStart(2, '0')}dk`;
  }
  if (mins > 0) {
    return `${mins}dk ${String(secs).padStart(2, '0')}sn`;
  }
  return `${secs}sn`;
}

export type CountdownUrgency = 'normal' | 'urgent' | 'critical';

export function countdownUrgency(ms: number): CountdownUrgency {
  if (ms <= 3600_000) return 'critical';
  if (ms <= 24 * 3600_000) return 'urgent';
  return 'normal';
}

export function useCountdown(deadline: string, active: boolean): number {
  const [remaining, setRemaining] = useState(() => getRemainingMs(deadline));

  useEffect(() => {
    if (!active) return;
    setRemaining(getRemainingMs(deadline));
    const id = setInterval(() => setRemaining(getRemainingMs(deadline)), 1000);
    return () => clearInterval(id);
  }, [deadline, active]);

  return remaining;
}
