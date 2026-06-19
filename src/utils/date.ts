function parseDate(iso: string): Date {
  return new Date(iso);
}

function addHours(iso: string, hours: number): Date {
  return new Date(parseDate(iso).getTime() + hours * 3_600_000);
}

/** Cihazın yerel saat diliminde tarih + saat */
export function formatDate(iso: string): string {
  try {
    return new Intl.DateTimeFormat('tr-TR', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    }).format(parseDate(iso));
  } catch {
    return iso;
  }
}

/** Cihazın yerel saat diliminde sadece saat */
export function formatTime(iso: string | Date): string {
  try {
    const d = typeof iso === 'string' ? parseDate(iso) : iso;
    return new Intl.DateTimeFormat('tr-TR', {
      hour: '2-digit',
      minute: '2-digit',
    }).format(d);
  } catch {
    return String(iso);
  }
}

/** Son tarih satırı; maç skorunda parantez içinde maç saati (deadline + 1 saat) */
export function formatDeadline(
  deadline: string,
  options?: {
    eventType?: string;
    label?: 'bitis' | 'son_tarih';
  },
): string {
  const prefix = options?.label === 'bitis' ? 'Bitiş' : 'Son tarih';
  const dateStr = formatDate(deadline);

  if (options?.eventType === 'match_score') {
    const matchTime = formatTime(addHours(deadline, 1));
    return `${prefix}: ${dateStr} (Maç: ${matchTime})`;
  }

  return `${prefix}: ${dateStr}`;
}

export function eventTypeLabel(type: string): string {
  switch (type) {
    case 'match_score':
      return 'Maç Skoru';
    case 'champion':
      return 'Şampiyon';
    case 'runner_up':
      return 'İkinci';
    case 'third_place':
      return 'Üçüncü';
    default:
      return type;
  }
}

export function statusLabel(status: string): string {
  switch (status) {
    case 'open':
      return 'Açık';
    case 'locked':
      return 'Kilitli';
    case 'completed':
      return 'Tamamlandı';
    default:
      return status;
  }
}

export function formatChoice(
  type: string,
  choice: Record<string, unknown>,
): string {
  if (type === 'match_score') {
    return `${choice.home_score ?? '?'} - ${choice.away_score ?? '?'}`;
  }
  if (choice.team) return String(choice.team);
  return JSON.stringify(choice);
}

export function formatResult(
  type: string,
  result: Record<string, unknown>,
): string {
  return formatChoice(type, result);
}

export function pointsClass(points: number): 'points-won' | 'points-zero' {
  return points > 0 ? 'points-won' : 'points-zero';
}
