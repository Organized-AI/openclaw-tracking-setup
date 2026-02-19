import Conf from 'conf';
import type { StapeConfig } from '../types.js';

const config = new Conf<StapeConfig>({
  projectName: 'stape-cli',
  schema: {
    stapeApiKey: { type: 'string' },
    stapeRegion: { type: 'string', enum: ['default', 'eu'], default: 'default' },
    gtmAccountId: { type: 'string' },
    gtmWebContainerId: { type: 'string' },
    gtmServerContainerId: { type: 'string' },
    gtmWorkspaceId: { type: 'string' }
  }
});

export function getConfig(): StapeConfig {
  return config.store;
}

export function setConfig(key: keyof StapeConfig, value: string): void {
  config.set(key, value);
}

export function setFullConfig(newConfig: Partial<StapeConfig>): void {
  for (const [key, value] of Object.entries(newConfig)) {
    if (value !== undefined) {
      config.set(key as keyof StapeConfig, value);
    }
  }
}

export function clearConfig(): void {
  config.clear();
}

export function getConfigPath(): string {
  return config.path;
}

export function hasRequiredGTMConfig(): boolean {
  const cfg = getConfig();
  return !!(cfg.gtmAccountId && cfg.gtmWorkspaceId);
}

export function hasStapeConfig(): boolean {
  const cfg = getConfig();
  return !!cfg.stapeApiKey;
}
