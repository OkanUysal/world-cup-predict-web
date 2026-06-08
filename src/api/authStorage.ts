import type { UserProfile } from '../types';

const TOKEN_KEY = 'wcp_token';
const USER_KEY = 'wcp_user';
const CREDENTIALS_KEY = 'wcp_credentials';

export interface StoredCredentials {
  name: string;
  password: string;
  channel_code?: string;
}

export function getStoredToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function getStoredUser(): UserProfile | null {
  const raw = localStorage.getItem(USER_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as UserProfile;
  } catch {
    return null;
  }
}

export function getStoredCredentials(): StoredCredentials | null {
  const raw = localStorage.getItem(CREDENTIALS_KEY);
  if (!raw) return null;
  try {
    const data = JSON.parse(raw) as StoredCredentials;
    if (!data.name || !data.password) return null;
    return data;
  } catch {
    return null;
  }
}

export function saveSession(token: string, user: UserProfile) {
  localStorage.setItem(TOKEN_KEY, token);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function saveCredentials(credentials: StoredCredentials) {
  localStorage.setItem(
    CREDENTIALS_KEY,
    JSON.stringify({
      name: credentials.name,
      password: credentials.password,
      ...(credentials.channel_code
        ? { channel_code: credentials.channel_code }
        : {}),
    }),
  );
}

export function clearSession() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

export function clearCredentials() {
  localStorage.removeItem(CREDENTIALS_KEY);
}

export function clearAllAuth() {
  clearSession();
  clearCredentials();
}
