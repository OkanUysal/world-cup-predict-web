export interface Channel {
  id: string;
  code: string;
  name: string;
}

export interface UserProfile {
  id: string;
  name: string;
  role: 'user' | 'admin';
  channel_id?: string;
  channel?: Channel;
  total_points?: number;
}

export interface AuthResponse {
  access_token: string;
  expires_at: string;
  user: UserProfile;
}

export interface Event {
  id: string;
  type: 'match_score' | 'champion' | 'runner_up' | 'third_place';
  title: string;
  metadata: Record<string, unknown>;
  deadline: string;
  status: 'open' | 'locked' | 'completed';
  result?: Record<string, unknown>;
  created_at: string;
}

export interface Prediction {
  id: string;
  event_id: string;
  user_id: string;
  user_name?: string;
  choice: Record<string, unknown>;
  points_awarded: number;
  created_at: string;
  updated_at: string;
}

export interface EventWithPrediction {
  event: Event;
  my_prediction?: Prediction;
}

export interface EventDetailResponse {
  event: Event;
  my_prediction?: Prediction | null;
}

export interface UserScore {
  user_id: string;
  user_name: string;
  channel_id: string;
  total_points: number;
  updated_at: string;
}

export type EventStatusFilter = 'open' | 'pending' | 'completed';
