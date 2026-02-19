import type { StapeConfig } from '../types.js';

export class StapeAPI {
  private baseUrl = 'https://api.stape.io';
  private apiKey: string;

  constructor(private config: StapeConfig) {
    this.apiKey = config.stapeApiKey || '';
    if (config.stapeRegion === 'eu') {
      this.baseUrl = 'https://api.eu.stape.io';
    }
  }

  async request(endpoint: string, options: RequestInit = {}): Promise<any> {
    const url = `${this.baseUrl}${endpoint}`;
    const headers = {
      'Authorization': `Bearer ${this.apiKey}`,
      'Content-Type': 'application/json',
      ...options.headers
    };

    const response = await fetch(url, {
      ...options,
      headers
    });

    if (!response.ok) {
      throw new Error(`Stape API error: ${response.statusText}`);
    }

    return response.json();
  }

  async listContainers() {
    return this.request('/v1/containers');
  }

  async getContainer(containerId: string) {
    return this.request(`/v1/containers/${containerId}`);
  }

  async getStatus() {
    return this.request('/v1/status');
  }
}
