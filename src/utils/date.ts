export function formatDate(iso: string): string {
  try {
    return new Intl.DateTimeFormat('tr-TR', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      timeZone: 'UTC',
    }).format(new Date(iso));
  } catch {
    return iso;
  }
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
