import { FormEvent, useEffect, useState } from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import { getStoredCredentials } from '../api/client';
import { useAuth } from '../context/AuthContext';

export default function AuthPage() {
  const { token, loading, login, register } = useAuth();
  const navigate = useNavigate();
  const [tab, setTab] = useState<'login' | 'register'>('login');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const [name, setName] = useState('');
  const [password, setPassword] = useState('');
  const [channelCode, setChannelCode] = useState('');

  useEffect(() => {
    const saved = getStoredCredentials();
    if (saved) {
      setName(saved.name);
      setPassword(saved.password);
      setChannelCode(saved.channel_code ?? '');
    }
  }, []);

  if (!loading && token) {
    return <Navigate to="/events" replace />;
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError('');
    setSubmitting(true);
    try {
      if (tab === 'login') {
        await login({
          name: name.trim(),
          password,
          channel_code: channelCode.trim() || undefined,
        });
      } else {
        await register({
          name: name.trim(),
          password,
          channel_code: channelCode.trim(),
        });
      }
      navigate('/events');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Bir hata oluştu');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-header">
          <span className="logo">⚽</span>
          <h1>Dünya Kupası Tahmin</h1>
          <p>Arkadaşlarınla tahmin yap, puan topla!</p>
          <p className="version">v2.0.0 · /api/v1</p>
        </div>

        <div className="tabs">
          <button
            type="button"
            className={tab === 'login' ? 'active' : ''}
            onClick={() => {
              setTab('login');
              setError('');
            }}
          >
            Giriş
          </button>
          <button
            type="button"
            className={tab === 'register' ? 'active' : ''}
            onClick={() => {
              setTab('register');
              setError('');
            }}
          >
            Kayıt
          </button>
        </div>

        {error && <div className="error-box">{error}</div>}

        <form onSubmit={handleSubmit}>
          <label>
            Kullanıcı Adı
            <input
              value={name}
              onChange={(e) => setName(e.target.value)}
              required
              autoComplete="username"
            />
          </label>
          <label>
            Şifre
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              minLength={tab === 'register' ? 6 : undefined}
              autoComplete={
                tab === 'login' ? 'current-password' : 'new-password'
              }
            />
          </label>
          <label>
            Kanal Kodu {tab === 'login' ? '(opsiyonel)' : ''}
            <input
              value={channelCode}
              onChange={(e) => setChannelCode(e.target.value)}
              required={tab === 'register'}
            />
          </label>
          <button type="submit" className="btn-primary" disabled={submitting}>
            {submitting ? 'Bekleyin…' : tab === 'login' ? 'Giriş Yap' : 'Kayıt Ol'}
          </button>
        </form>
      </div>
    </div>
  );
}
