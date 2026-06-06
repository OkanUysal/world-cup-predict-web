import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import BottomNav from './BottomNav';

export default function Layout() {
  const { token, loading, user } = useAuth();
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
      {channelName && (
        <header className="app-top-bar">
          <span className="app-top-bar-icon">⚽</span>
          <h1 className="app-top-bar-title">{channelName}</h1>
        </header>
      )}
      <main className="main-content">
        <Outlet />
      </main>
      <BottomNav />
    </div>
  );
}
