import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import {
  api,
  clearAllAuth,
  clearSession,
  getStoredCredentials,
  getStoredToken,
  getStoredUser,
  saveSession,
  setSessionListener,
  silentReLogin,
} from '../api/client';
import type { AuthResponse, UserProfile } from '../types';

interface AuthContextValue {
  user: UserProfile | null;
  token: string | null;
  loading: boolean;
  login: (data: {
    name: string;
    password: string;
    channel_code?: string;
  }) => Promise<void>;
  register: (data: {
    name: string;
    password: string;
    channel_code: string;
  }) => Promise<void>;
  logout: () => void;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<UserProfile | null>(getStoredUser());
  const [token, setToken] = useState<string | null>(getStoredToken());
  const [loading, setLoading] = useState(true);

  const applySession = useCallback((res: AuthResponse) => {
    saveSession(res.access_token, res.user);
    setToken(res.access_token);
    setUser(res.user);
  }, []);

  const refreshProfile = useCallback(async () => {
    if (!getStoredToken()) return;
    try {
      const profile = await api.getMe();
      setUser(profile);
      saveSession(getStoredToken()!, profile);
    } catch {
      // Sessiz yenileme init veya 401 handler'da yapılır
    }
  }, []);

  const restoreSession = useCallback(async () => {
    const credentials = getStoredCredentials();
    const existingToken = getStoredToken();

    if (existingToken) {
      try {
        const profile = await api.getMe();
        setToken(existingToken);
        setUser(profile);
        saveSession(existingToken, profile);
        return;
      } catch {
        // Token geçersiz — kayıtlı bilgilerle yeniden giriş dene
      }
    }

    if (credentials) {
      const ok = await silentReLogin();
      if (ok) {
        await refreshProfile();
        setToken(getStoredToken());
        setUser(getStoredUser());
        return;
      }
      clearSession();
      setToken(null);
      setUser(null);
      return;
    }

    if (existingToken) {
      clearSession();
    }
    setToken(null);
    setUser(null);
  }, [refreshProfile]);

  useEffect(() => {
    setSessionListener((newToken, newUser) => {
      setToken(newToken);
      setUser(newUser);
    });
    return () => setSessionListener(null);
  }, []);

  useEffect(() => {
    (async () => {
      await restoreSession();
      setLoading(false);
    })();
  }, [restoreSession]);

  const login = useCallback(
    async (data: {
      name: string;
      password: string;
      channel_code?: string;
    }) => {
      const res = await api.login(data);
      applySession(res);
      await refreshProfile();
    },
    [applySession, refreshProfile],
  );

  const register = useCallback(
    async (data: {
      name: string;
      password: string;
      channel_code: string;
    }) => {
      const res = await api.register(data);
      applySession(res);
      await refreshProfile();
    },
    [applySession, refreshProfile],
  );

  const logout = useCallback(() => {
    clearAllAuth();
    setToken(null);
    setUser(null);
  }, []);

  const value = useMemo(
    () => ({
      user,
      token,
      loading,
      login,
      register,
      logout,
      refreshProfile,
    }),
    [user, token, loading, login, register, logout, refreshProfile],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
