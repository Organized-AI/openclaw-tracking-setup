#!/usr/bin/env node

import { program } from 'commander';
import { printBanner } from './utils/display.js';
import configCommand from './commands/config.js';
import ga4Command from './commands/ga4.js';
import gtmCommand from './commands/gtm.js';
import installCommand from './commands/install.js';
import stapeCommand from './commands/stape.js';

printBanner();

program
  .name('stape')
  .description('Unified CLI for Stape ecosystem')
  .version('1.0.0');

program.addCommand(configCommand);
program.addCommand(ga4Command);
program.addCommand(gtmCommand);
program.addCommand(installCommand);
program.addCommand(stapeCommand);

program.parse(process.argv);
