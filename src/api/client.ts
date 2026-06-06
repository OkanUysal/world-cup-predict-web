const API_BASE = '/api/v1';

const TOKEN_KEY = 'wcp_token';
const USER_KEY = 'wcp_user';

export function getStoredToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function getStoredUser() {
  const raw = localStorage.getItem(USER_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

export function saveSession(token: string, user: unknown) {
  localStorage.setItem(TOKEN_KEY, token);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function clearSession() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

async function request<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
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
    throw new Error(err);
  }

  return data as T;
}

export const api = {
  login(body: {
    name: string;
    password: string;
    channel_code?: string;
  }) {
    return request<import('../types').AuthResponse>('/auth/login', {
      method: 'POST',
      body: JSON.stringify(body),
    });
  },

  register(body: {
    name: string;
    password: string;
    channel_code: string;
  }) {
    return request<import('../types').AuthResponse>('/auth/register', {
      method: 'POST',
      body: JSON.stringify(body),
    });
  },

  getMe() {
    return request<import('../types').UserProfile>('/me');
  },

  getLeaderboard() {
    return request<import('../types').UserScore[]>('/leaderboard');
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
