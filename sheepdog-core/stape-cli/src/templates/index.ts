export const templates = {
  'facebook-capi': {
    name: 'Facebook Conversions API',
    description: 'Setup Facebook CAPI integration for server-side conversion tracking',
    tags: ['facebook', 'capi', 'conversions'],
    version: '1.0.0'
  },
  'tiktok-events': {
    name: 'TikTok Events API',
    description: 'Setup TikTok Events API for server-side event tracking',
    tags: ['tiktok', 'events', 'tracking'],
    version: '1.0.0'
  },
  'linkedin-capi': {
    name: 'LinkedIn Conversions API',
    description: 'Setup LinkedIn CAPI for lead tracking and conversion reporting',
    tags: ['linkedin', 'capi', 'leads'],
    version: '1.0.0'
  },
  'shopify': {
    name: 'Shopify E-commerce Tracking',
    description: 'Setup e-commerce tracking for Shopify stores',
    tags: ['shopify', 'ecommerce', 'tracking'],
    version: '1.0.0'
  },
  'woocommerce': {
    name: 'WooCommerce Tracking',
    description: 'Setup e-commerce tracking for WooCommerce stores',
    tags: ['woocommerce', 'ecommerce', 'wordpress'],
    version: '1.0.0'
  }
};

export function getTemplate(name: string) {
  return templates[name as keyof typeof templates];
}

export function listTemplates() {
  return Object.entries(templates).map(([key, value]) => ({
    id: key,
    ...value
  }));
}
