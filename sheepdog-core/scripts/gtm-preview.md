# GTM Preview Mode

Instructions for using GTM Preview and Debug mode.

## Overview

Google Tag Manager's Preview mode allows you to test tags, triggers, and variables before publishing them to your live container.

## Accessing Preview Mode

1. In GTM, click the **Preview** button in the top right
2. This generates a preview URL that you can share
3. Install the preview mode extension or cookie from the provided link
4. Preview mode is valid for 30 minutes

## Debug Mode

The GTM Debug Console shows real-time information about:

- Tags that fired
- Data layer variables
- Trigger conditions
- Errors and warnings

## Testing Workflow

1. Enable preview mode
2. Navigate to your website
3. Open the debug console (bottom-left icon)
4. Perform user actions to trigger tags
5. Verify tags fire correctly
6. Check data being sent
7. Disable preview and publish

## Common Issues

- **Tags not firing**: Check trigger conditions in debug console
- **Wrong data**: Verify data layer variable naming
- **Events missing**: Ensure event firing logic is correct
