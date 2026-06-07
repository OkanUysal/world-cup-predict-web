import { FormEvent, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/client';
import { useAuth } from '../context/AuthContext';
import { usePreferences, type CardSize, type Theme } from '../context/PreferencesContext';
import { displayName } from '../utils/user';

export default function ProfilePage() {
  const { user, logout, refreshProfile } = useAuth();
  const { cardSize, theme, setCardSize, setTheme } = usePreferences();
  const navigate = useNavigate();

  const [nickname, setNickname] = useState('');
  const [nicknameError, setNicknameError] = useState('');
  const [nicknameSaving, setNicknameSaving] = useState(false);
  const [nicknameMsg, setNicknameMsg] = useState('');

  useEffect(() => {
    setNickname(user?.nickname ?? '');
  }, [user]);

  function handleLogout() {
    logout();
    navigate('/login');
  }

  async function handleNicknameSubmit(e: FormEvent) {
    e.preventDefault();
    setNicknameError('');
    setNicknameMsg('');

    const trimmed = nickname.trim();
    if (trimmed.length > 0 && (trimmed.length < 2 || trimmed.length > 64)) {
      setNicknameError('Nickname 2–64 karakter olmalı');
      return;
    }

    setNicknameSaving(true);
    try {
      await api.updateNickname(trimmed);
      await refreshProfile();
      setNicknameMsg(trimmed ? 'Nickname kaydedildi' : 'Nickname temizlendi');
    } catch (err) {
      setNicknameError(err instanceof Error ? err.message : 'Kaydedilemedi');
    } finally {
      setNicknameSaving(false);
    }
  }

  if (!user) return null;

  const shownName = displayName(user);

  return (
    <div className="page">
      <div className="card profile-card">
        <div className="avatar">{shownName.charAt(0).toUpperCase()}</div>
        <h2>{shownName}</h2>
        {user.nickname?.trim() && (
          <p className="muted small">Kullanıcı adı: {user.name}</p>
        )}
        {user.channel && <p className="muted">{user.channel.name}</p>}
        <p className="muted">Rol: {user.role === 'admin' ? 'Admin' : 'Kullanıcı'}</p>
        {user.total_points !== undefined && (
          <p className="points-big">{user.total_points} puan</p>
        )}
      </div>

      <div className="card settings-card">
        <h3 className="settings-title">Görünen isim</h3>
        <form onSubmit={handleNicknameSubmit}>
          <label className="field-label">
            Nickname
            <input
              value={nickname}
              onChange={(e) => {
                setNickname(e.target.value);
                setNicknameError('');
                setNicknameMsg('');
              }}
              placeholder="Boş bırakırsan kullanıcı adın görünür"
              maxLength={64}
            />
          </label>
          {nicknameError && <p className="inline-error">{nicknameError}</p>}
          {nicknameMsg && <p className="inline-success">{nicknameMsg}</p>}
          <div className="settings-actions">
            <button
              type="submit"
              className="btn-save"
              disabled={nicknameSaving}
            >
              {nicknameSaving ? 'Kaydediliyor…' : 'Kaydet'}
            </button>
            {user.nickname && (
              <button
                type="button"
                className="btn-secondary"
                disabled={nicknameSaving}
                onClick={async () => {
                  setNicknameError('');
                  setNicknameMsg('');
                  setNicknameSaving(true);
                  try {
                    await api.updateNickname('');
                    setNickname('');
                    await refreshProfile();
                    setNicknameMsg('Nickname temizlendi');
                  } catch (err) {
                    setNicknameError(
                      err instanceof Error ? err.message : 'Kaydedilemedi',
                    );
                  } finally {
                    setNicknameSaving(false);
                  }
                }}
              >
                Temizle
              </button>
            )}
          </div>
        </form>
      </div>

      <div className="card settings-card">
        <h3 className="settings-title">Görünüm</h3>

        <div className="setting-row">
          <span className="setting-label">Kart boyutu</span>
          <div className="segmented">
            {(['small', 'large'] as CardSize[]).map((size) => (
              <button
                key={size}
                type="button"
                className={cardSize === size ? 'active' : ''}
                onClick={() => setCardSize(size)}
              >
                {size === 'small' ? 'Küçük' : 'Büyük'}
              </button>
            ))}
          </div>
        </div>

        <div className="setting-row">
          <span className="setting-label">Tema</span>
          <div className="segmented">
            {(['light', 'dark'] as Theme[]).map((t) => (
              <button
                key={t}
                type="button"
                className={theme === t ? 'active' : ''}
                onClick={() => setTheme(t)}
              >
                {t === 'light' ? 'Açık' : 'Koyu'}
              </button>
            ))}
          </div>
        </div>
      </div>

      <div className="actions">
        <button type="button" className="btn-secondary" onClick={() => refreshProfile()}>
          Profili Yenile
        </button>
        <button type="button" className="btn-danger" onClick={handleLogout}>
          Çıkış Yap
        </button>
      </div>
    </div>
  );
}
