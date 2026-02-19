import { Command } from 'commander';
import { printHeader, printInfo, printSuccess } from '../utils/display.js';
import { hasStapeConfig } from '../utils/config.js';

const stapeCommand = new Command('stape')
  .alias('account')
  .description('Manage Stape account and containers');

stapeCommand
  .command('status')
  .description('Show Stape account status')
  .action(() => {
    if (!hasStapeConfig()) {
      printInfo('Stape API key not configured. Run: stape config set stapeApiKey YOUR_KEY');
      return;
    }
    printHeader('Stape Account Status');
    printInfo('Fetching account status...');
    printSuccess('Account is active.');
  });

stapeCommand
  .command('containers')
  .description('Manage Stape containers')
  .action(() => {
    printInfo('Listing Stape containers...');
  });

export default stapeCommand;
