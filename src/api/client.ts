import type { AuthResponse, UserProfile } from '../types';
import {
  getStoredCredentials,
  getStoredToken,
  saveCredentials,
  saveSession,
  type StoredCredentials,
} from './authStorage';

const API_BASE = '/api/v1';

export {
  clearAllAuth,
  clearCredentials,
  clearSession,
  getStoredCredentials,
  getStoredToken,
  getStoredUser,
  saveCredentials,
  saveSession,
} from './authStorage';

type SessionListener = (token: string, user: UserProfile) => void;

let sessionListener: SessionListener | null = null;
let reloginPromise: Promise<boolean> | null = null;

export function setSessionListener(listener: SessionListener | null) {
  sessionListener = listener;
}

function notifySession(token: string, user: UserProfile) {
  sessionListener?.(token, user);
}

async function parseResponse<T>(res: Response): Promise<T> {
  let data: unknown = null;
  const text = await res.text();
  if (text) {
    try {
      data = JSON.parse(text);
    } catch {
      if (!res.ok) throw new Error(text);
      throw new Error('Geçersiz sunucu yanıtı');
    }
  }

  if (!res.ok) {
    const err =
      data && typeof data === 'object' && 'error' in data
        ? String((data as { error: string }).error)
        : `İstek başarısız (${res.status})`;
    const error = new Error(err) as Error & { status?: number };
    error.status = res.status;
    throw error;
  }

  return data as T;
}

async function authLogin(
  body: StoredCredentials,
): Promise<AuthResponse> {
  const res = await fetch(`${API_BASE}/auth/login`, {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      name: body.name,
      password: body.password,
      ...(body.channel_code ? { channel_code: body.channel_code } : {}),
    }),
  });
  return parseResponse<AuthResponse>(res);
}

export async function silentReLogin(): Promise<boolean> {
  const credentials = getStoredCredentials();
  if (!credentials) return false;

  if (!reloginPromise) {
    reloginPromise = (async () => {
      try {
        const res = await authLogin(credentials);
        saveSession(res.access_token, res.user);
        notifySession(res.access_token, res.user);
        return true;
      } catch {
        return false;
      } finally {
        reloginPromise = null;
      }
    })();
  }

  return reloginPromise;
}

type RequestOptions = RequestInit & { _retried?: boolean };

async function request<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const token = getStoredToken();
  const headers: Record<string, string> = {
    Accept: 'application/json',
    ...(options.headers as Record<string, string>),
  };

  if (options.body && !headers['Content-Type']) {
    headers['Content-Type'] = 'application/json';
  }

  if (token && !path.includes('/auth/')) {
    headers.Authorization = `Bearer ${token}`;
  }

  const res = await fetch(`${API_BASE}${path}`, { ...options, headers });

  if (
    res.status === 401 &&
    !path.includes('/auth/') &&
    !options._retried
  ) {
    const ok = await silentReLogin();
    if (ok) {
      return request<T>(path, { ...options, _retried: true });
    }
  }

  return parseResponse<T>(res);
}

export const api = {
  login(body: {
    name: string;
    password: string;
    channel_code?: string;
  }) {
    saveCredentials({
      name: body.name,
      password: body.password,
      channel_code: body.channel_code,
    });
    return request<AuthResponse>('/auth/login', {
      method: 'POST',
      body: JSON.stringify(body),
    });
  },

  register(body: {
    name: string;
    password: string;
    channel_code: string;
  }) {
    saveCredentials({
      name: body.name,
      password: body.password,
      channel_code: body.channel_code,
    });
    return request<AuthResponse>('/auth/register', {
      method: 'POST',
      body: JSON.stringify(body),
    });
  },

  getMe() {
    return request<UserProfile>('/me');
  },

  updateNickname(nickname: string) {
    return request<UserProfile>('/me/nickname', {
      method: 'PATCH',
      body: JSON.stringify({ nickname }),
    });
  },

  getLeaderboard() {
    return request<import('../types').UserScore[]>('/leaderboard');
  },

  getUserPredictions(userId: string) {
    return request<import('../types').UserPredictionResponse[]>(`/users/${userId}/predictions`);
  },

  getEvents(status: import('../types').EventStatusFilter) {
    return request<import('../types').EventWithPrediction[]>(
      `/events?status=${status}`,
    );
  },

  getEvent(id: string) {
    return request<import('../types').EventDetailResponse>(`/events/${id}`);
  },

  getEventPredictions(id: string) {
    return request<import('../types').Prediction[]>(`/events/${id}/predictions`);
  },

  submitPrediction(id: string, choice: Record<string, unknown>) {
    return request<import('../types').Prediction>(`/events/${id}/prediction`, {
      method: 'PUT',
      body: JSON.stringify({ choice }),
    });
  },
};
