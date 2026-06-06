import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function ProfilePage() {
  const { user, logout, refreshProfile } = useAuth();
  const navigate = useNavigate();

  function handleLogout() {
    logout();
    navigate('/login');
  }

  return (
    <div className="page">
      <header className="page-header">
        <h1>Profil</h1>
      </header>

      {user && (
        <div className="card profile-card">
          <div className="avatar">{user.name.charAt(0).toUpperCase()}</div>
          <h2>{user.name}</h2>
          <p className="muted">Rol: {user.role === 'admin' ? 'Admin' : 'Kullanıcı'}</p>
          {user.total_points !== undefined && (
            <p className="points-big">{user.total_points} puan</p>
          )}
        </div>
      )}

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
