import chalk from 'chalk';
import { table } from 'table';
import ora, { type Ora } from 'ora';

export const spinner = {
  start(text: string): Ora {
    return ora(text).start();
  },
  succeed(spinner: Ora, text?: string): void {
    spinner.succeed(text);
  },
  fail(spinner: Ora, text?: string): void {
    spinner.fail(text);
  },
  warn(spinner: Ora, text?: string): void {
    spinner.warn(text);
  }
};

export function printHeader(text: string): void {
  console.log();
  console.log(chalk.bold.cyan('\u2501'.repeat(60)));
  console.log(chalk.bold.cyan(`  ${text}`));
  console.log(chalk.bold.cyan('\u2501'.repeat(60)));
  console.log();
}

export function printSubheader(text: string): void {
  console.log();
  console.log(chalk.bold.white(`\u25b8 ${text}`));
  console.log(chalk.gray('\u2500'.repeat(40)));
}

export function printSuccess(text: string): void {
  console.log(chalk.green(`\u2713 ${text}`));
}

export function printError(text: string): void {
  console.log(chalk.red(`\u2717 ${text}`));
}

export function printWarning(text: string): void {
  console.log(chalk.yellow(`\u26a0 ${text}`));
}

export function printInfo(text: string): void {
  console.log(chalk.blue(`\u2139 ${text}`));
}

export function printTable(headers: string[], rows: string[][]): void {
  const data = [headers.map(h => chalk.bold.white(h)), ...rows];
  console.log(table(data, {
    border: {
      topBody: chalk.gray('\u2500'),
      topJoin: chalk.gray('\u252c'),
      topLeft: chalk.gray('\u250c'),
      topRight: chalk.gray('\u2510'),
      bottomBody: chalk.gray('\u2500'),
      bottomJoin: chalk.gray('\u2534'),
      bottomLeft: chalk.gray('\u2514'),
      bottomRight: chalk.gray('\u2518'),
      bodyLeft: chalk.gray('\u2502'),
      bodyRight: chalk.gray('\u2502'),
      bodyJoin: chalk.gray('\u2502'),
      joinBody: chalk.gray('\u2500'),
      joinLeft: chalk.gray('\u251c'),
      joinRight: chalk.gray('\u2524'),
      joinJoin: chalk.gray('\u253c')
    }
  }));
}

export function printKeyValue(pairs: Record<string, string | undefined>): void {
  for (const [key, value] of Object.entries(pairs)) {
    if (value !== undefined) {
      console.log(`  ${chalk.gray(key + ':')} ${chalk.white(value)}`);
    }
  }
}

export function printCode(code: string, language?: string): void {
  console.log();
  console.log(chalk.gray('```' + (language || '')));
  console.log(chalk.yellow(code));
  console.log(chalk.gray('```'));
  console.log();
}

export function printBanner(): void {
  console.log(chalk.cyan(`
  \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557 \u2588\u2588\u2588\u2588\u2588\u2557 \u2588\u2588\u2588\u2588\u2588\u2588\u2557 \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557     \u2588\u2588\u2588\u2588\u2588\u2588\u2557\u2588\u2588\u2557     \u2588\u2588\u2557
  \u2588\u2588\u2554\u2550\u2550\u2550\u2550\u255d\u255a\u2550\u2550\u2588\u2588\u2554\u2550\u2550\u255d\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2554\u2550\u2550\u2550\u2550\u255d    \u2588\u2588\u2554\u2550\u2550\u2550\u2550\u255d\u2588\u2588\u2551     \u2588\u2588\u2551
  \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557   \u2588\u2588\u2551   \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2551\u2588\u2588\u2588\u2588\u2588\u2588\u2554\u255d\u2588\u2588\u2588\u2588\u2588\u2557      \u2588\u2588\u2551     \u2588\u2588\u2551     \u2588\u2588\u2551
  \u255a\u2550\u2550\u2550\u2550\u2588\u2588\u2551   \u2588\u2588\u2551   \u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2551\u2588\u2588\u2554\u2550\u2550\u2550\u255d \u2588\u2588\u2554\u2550\u2550\u255d      \u2588\u2588\u2551     \u2588\u2588\u2551     \u2588\u2588\u2551
  \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2551   \u2588\u2588\u2551   \u2588\u2588\u2551  \u2588\u2588\u2551\u2588\u2588\u2551     \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557    \u255a\u2588\u2588\u2588\u2588\u2588\u2588\u2557\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557\u2588\u2588\u2551
  \u255a\u2550\u2550\u2550\u2550\u2550\u2550\u255d   \u255a\u2550\u255d   \u255a\u2550\u255d  \u255a\u2550\u255d\u255a\u2550\u255d     \u255a\u2550\u2550\u2550\u2550\u2550\u2550\u255d     \u255a\u2550\u2550\u2550\u2550\u2550\u255d\u255a\u2550\u2550\u2550\u2550\u2550\u2550\u255d\u255a\u2550\u255d
  `));
  console.log(chalk.gray('  Unified CLI for Stape Ecosystem - GTM, sGTM, CAPI & More'));
  console.log(chalk.gray('  Version 1.0.0 | https://stape.io'));
  console.log();
}
