import { NavLink } from 'react-router-dom';

export default function BottomNav() {
  return (
    <nav className="bottom-nav">
      <NavLink to="/events" className={({ isActive }) => (isActive ? 'active' : '')}>
        <span>⚽</span>
        Tahminler
      </NavLink>
      <NavLink
        to="/leaderboard"
        className={({ isActive }) => (isActive ? 'active' : '')}
      >
        <span>🏆</span>
        Sıralama
      </NavLink>
      <NavLink to="/profile" className={({ isActive }) => (isActive ? 'active' : '')}>
        <span>👤</span>
        Profil
      </NavLink>
    </nav>
  );
}
