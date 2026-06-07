import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
import './index.css';

document.documentElement.dataset.theme =
  localStorage.getItem('wcp_theme') === 'dark' ? 'dark' : 'light';
document.documentElement.dataset.cardSize =
  localStorage.getItem('wcp_card_size') === 'large' ? 'large' : 'small';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
