import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';

export type CardSize = 'small' | 'large';
export type Theme = 'light' | 'dark';

const CARD_SIZE_KEY = 'wcp_card_size';
const THEME_KEY = 'wcp_theme';

interface PreferencesContextValue {
  cardSize: CardSize;
  theme: Theme;
  setCardSize: (size: CardSize) => void;
  setTheme: (theme: Theme) => void;
}

const PreferencesContext = createContext<PreferencesContextValue | null>(null);

function readCardSize(): CardSize {
  const v = localStorage.getItem(CARD_SIZE_KEY);
  return v === 'large' ? 'large' : 'small';
}

function readTheme(): Theme {
  const v = localStorage.getItem(THEME_KEY);
  return v === 'dark' ? 'dark' : 'light';
}

export function PreferencesProvider({ children }: { children: ReactNode }) {
  const [cardSize, setCardSizeState] = useState<CardSize>(readCardSize);
  const [theme, setThemeState] = useState<Theme>(readTheme);

  const setCardSize = useCallback((size: CardSize) => {
    setCardSizeState(size);
    localStorage.setItem(CARD_SIZE_KEY, size);
  }, []);

  const setTheme = useCallback((t: Theme) => {
    setThemeState(t);
    localStorage.setItem(THEME_KEY, t);
  }, []);

  useEffect(() => {
    document.documentElement.dataset.cardSize = cardSize;
    document.documentElement.dataset.theme = theme;
  }, [cardSize, theme]);

  const value = useMemo(
    () => ({ cardSize, theme, setCardSize, setTheme }),
    [cardSize, theme, setCardSize, setTheme],
  );

  return (
    <PreferencesContext.Provider value={value}>
      {children}
    </PreferencesContext.Provider>
  );
}

export function usePreferences() {
  const ctx = useContext(PreferencesContext);
  if (!ctx) {
    throw new Error('usePreferences must be used within PreferencesProvider');
  }
  return ctx;
}
