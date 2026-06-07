import { useState } from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import BottomNav from './BottomNav';
import RulesModal from './RulesModal';

export default function Layout() {
  const { token, loading, user } = useAuth();
  const [rulesOpen, setRulesOpen] = useState(false);
  const channelName = user?.channel?.name;

  if (loading) {
    return (
      <div className="center-page">
        <div className="spinner" />
      </div>
    );
  }

  if (!token) {
    return <Navigate to="/login" replace />;
  }

  return (
    <div className="app-shell">
      <header className="app-top-bar">
        <div className="app-top-bar-left">
          <span className="app-top-bar-icon">⚽</span>
          <h1 className="app-top-bar-title">
            {channelName ?? 'Dünya Kupası Tahmin'}
          </h1>
        </div>
        <button
          type="button"
          className="rules-btn"
          onClick={() => setRulesOpen(true)}
          aria-label="Puanlama kuralları"
          title="Kurallar"
        >
          📋
        </button>
      </header>

      <main className="main-content">
        <Outlet />
      </main>
      <BottomNav />

      {rulesOpen && <RulesModal onClose={() => setRulesOpen(false)} />}
    </div>
  );
}
