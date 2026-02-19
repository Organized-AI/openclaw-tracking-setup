import { Command } from 'commander';
import { printHeader, printInfo, printSuccess } from '../utils/display.js';

const ga4Command = new Command('ga4')
  .description('Manage GA4 configuration and properties');

ga4Command
  .command('setup')
  .description('Initialize GA4 setup')
  .action(() => {
    printHeader('GA4 Setup');
    printInfo('GA4 setup wizard starting...');
    printSuccess('GA4 configuration initialized.');
  });

ga4Command
  .command('events')
  .description('Manage GA4 events')
  .action(() => {
    printInfo('GA4 events management');
  });

ga4Command
  .command('property')
  .description('Show GA4 property details')
  .action(() => {
    printInfo('Fetching GA4 property details...');
  });

export default ga4Command;
