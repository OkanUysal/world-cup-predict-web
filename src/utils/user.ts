export function displayName(user: {
  name: string;
  nickname?: string | null;
}): string {
  const nick = user.nickname?.trim();
  return nick || user.name;
}
