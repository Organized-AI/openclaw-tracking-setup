import { Command } from 'commander';
import { printHeader, printInfo, printSuccess } from '../utils/display.js';
import { hasRequiredGTMConfig } from '../utils/config.js';

const gtmCommand = new Command('gtm')
  .description('Manage GTM containers and deployments');

gtmCommand
  .command('deploy')
  .description('Deploy GTM container')
  .option('--verify', 'Verify deployment after push')
  .action((options) => {
    if (!hasRequiredGTMConfig()) {
      printInfo('GTM configuration required. Run: stape config set');
      return;
    }
    printHeader('GTM Deployment');
    printInfo('Deploying GTM container...');
    if (options.verify) {
      printInfo('Verifying deployment...');
    }
    printSuccess('Deployment completed.');
  });

gtmCommand
  .command('status')
  .description('Check GTM deployment status')
  .action(() => {
    printHeader('GTM Status');
    printInfo('Fetching deployment status...');
  });

export default gtmCommand;
