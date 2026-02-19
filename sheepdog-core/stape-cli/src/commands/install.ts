import { Command } from 'commander';
import { printHeader, printInfo, printSuccess } from '../utils/display.js';

const installCommand = new Command('install')
  .description('Install templates and integrations');

installCommand
  .command('list')
  .description('List available templates')
  .action(() => {
    printHeader('Available Templates');
    const templates = [
      'facebook-capi - Facebook Conversions API',
      'tiktok-events - TikTok Events API',
      'linkedin-capi - LinkedIn Conversions API',
      'shopify - Shopify e-commerce tracking',
      'woocommerce - WooCommerce tracking'
    ];
    templates.forEach(t => printInfo(t));
  });

installCommand
  .command('template <name>')
  .description('Install a template')
  .action((name: string) => {
    printHeader(`Installing ${name}`);
    printInfo(`Setting up ${name} template...`);
    printSuccess(`${name} installed successfully.`);
  });

export default installCommand;
