export interface StapeConfig {
  stapeApiKey?: string;
  stapeRegion?: 'default' | 'eu';
  gtmAccountId?: string;
  gtmWebContainerId?: string;
  gtmServerContainerId?: string;
  gtmWorkspaceId?: string;
}

export interface Container {
  id: string;
  name: string;
  type: 'web' | 'server';
  status: 'active' | 'paused' | 'archived';
  createdAt: string;
  updatedAt: string;
}

export interface Deployment {
  id: string;
  containerId: string;
  versionId: string;
  status: 'pending' | 'active' | 'failed';
  createdAt: string;
  completedAt?: string;
}

export interface Template {
  id: string;
  name: string;
  description: string;
  tags: string[];
  version: string;
}
