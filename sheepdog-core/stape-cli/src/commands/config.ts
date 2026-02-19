import { Command } from 'commander';
import { getConfig, setConfig, setFullConfig, clearConfig, getConfigPath } from '../utils/config.js';
import { printSuccess, printError, printKeyValue, printInfo } from '../utils/display.js';

const configCommand = new Command('config')
  .description('Manage Stape CLI configuration');

configCommand
  .command('show')
  .description('Show current configuration')
  .action(() => {
    const cfg = getConfig();
    if (Object.keys(cfg).length === 0) {
      printInfo('No configuration set yet.');
      printInfo(`Configuration file: ${getConfigPath()}`);
    } else {
      printKeyValue(cfg as Record<string, string | undefined>);
    }
  });

configCommand
  .command('set <key> <value>')
  .description('Set configuration value')
  .action((key: string, value: string) => {
    setConfig(key as any, value);
    printSuccess(`Configuration updated: ${key} = ${value}`);
  });

configCommand
  .command('get <key>')
  .description('Get configuration value')
  .action((key: string) => {
    const cfg = getConfig();
    const value = cfg[key as keyof typeof cfg];
    if (value) {
      console.log(value);
    } else {
      printError(`Configuration key not found: ${key}`);
    }
  });

configCommand
  .command('clear')
  .description('Clear all configuration')
  .action(() => {
    clearConfig();
    printSuccess('Configuration cleared.');
  });

export default configCommand;
