#!/usr/bin/env python3
"""
LinkedIn Conversions API (CAPI) Client

Send server-side conversion events to LinkedIn for improved measurement.

Dependencies: pip install requests --break-system-packages
Usage: python scripts/linkedin_capi.py --help
"""

import argparse
import hashlib
import json
import time
import requests
from typing import Optional, Dict, Any

class LinkedInCAPI:
    """LinkedIn Conversions API client."""

    BASE_URL = "https://api.linkedin.com/rest/conversionEvents"
    API_VERSION = "202401"

    def __init__(self, access_token: str, account_id: str):
        """Initialize CAPI client.

        Args:
            access_token: LinkedIn API access token
            account_id: LinkedIn Ads account ID
        """
        self.access_token = access_token
        self.account_id = account_id
        self.headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
            "LinkedIn-Version": self.API_VERSION,
            "X-Restli-Protocol-Version": "2.0.0"
        }

    @staticmethod
    def hash_sha256(value: str) -> Optional[str]:
        """Hash a value using SHA256 for LinkedIn matching.

        Args:
            value: Value to hash (email, phone, etc.)

        Returns:
            SHA256 hash of normalized value, or None if empty
        """
        if not value:
            return None

        # Normalize: lowercase and strip whitespace
        normalized = value.lower().strip()

        # Return SHA256 hash
        return hashlib.sha256(normalized.encode('utf-8')).hexdigest()

    def build_user_identifiers(self,
                                email: Optional[str] = None,
                                phone: Optional[str] = None,
                                li_fat_id: Optional[str] = None) -> list:
        """Build user identifiers array for matching.

        Args:
            email: User email address
            phone: User phone number (with country code)
            li_fat_id: LinkedIn first-party tracking ID

        Returns:
            List of user identifier objects
        """
        identifiers = []

        if email:
            identifiers.append({
                "idType": "SHA256_EMAIL",
                "idValue": self.hash_sha256(email)
            })

        if phone:
            # Remove spaces and special chars, keep + for country code
            clean_phone = ''.join(c for c in phone if c.isdigit() or c == '+')
            identifiers.append({
                "idType": "SHA256_PHONE",
                "idValue": self.hash_sha256(clean_phone)
            })

        if li_fat_id:
            identifiers.append({
                "idType": "LINKEDIN_FIRST_PARTY_ADS_TRACKING_UUID",
                "idValue": li_fat_id
            })

        return identifiers

    def send_event(self,
                   conversion_id: str,
                   event_id: str,
                   email: Optional[str] = None,
                   phone: Optional[str] = None,
                   li_fat_id: Optional[str] = None,
                   value: Optional[float] = None,
                   currency: str = "USD",
                   first_name: Optional[str] = None,
                   last_name: Optional[str] = None,
                   company: Optional[str] = None,
                   title: Optional[str] = None,
                   country: Optional[str] = None,
                   timestamp: Optional[int] = None) -> Dict[str, Any]:
        """Send a conversion event to LinkedIn CAPI.

        Args:
            conversion_id: LinkedIn conversion ID
            event_id: Unique event ID for deduplication
            email: User email
            phone: User phone
            li_fat_id: LinkedIn tracking ID
            value: Conversion value
            currency: Currency code (default USD)
            first_name: User first name
            last_name: User last name
            company: User company name
            title: User job title
            country: User country code
            timestamp: Event timestamp in milliseconds

        Returns:
            API response as dict
        """
        # Build conversion URN
        conversion_urn = f"urn:li:lyndaConversion:(urn:li:sponsoredAccount:{self.account_id},{conversion_id})"

        # Build payload
        payload = {
            "conversion": conversion_urn,
            "conversionHappenedAt": timestamp or int(time.time() * 1000),
            "eventId": event_id,
            "user": {
                "userIds": self.build_user_identifiers(email, phone, li_fat_id)
            }
        }

        # Add conversion value if provided
        if value is not None:
            payload["conversionValue"] = {
                "amount": str(value),
                "currencyCode": currency
            }

        # Add user info if provided
        user_info = {}
        if first_name:
            user_info["firstName"] = first_name
        if last_name:
            user_info["lastName"] = last_name
        if company:
            user_info["companyName"] = company
        if title:
            user_info["title"] = title
        if country:
            user_info["countryCode"] = country

        if user_info:
            payload["user"]["userInfo"] = user_info

        # Send request
        try:
            response = requests.post(
                self.BASE_URL,
                headers=self.headers,
                json=payload,
                timeout=30
            )

            result = {
                "status_code": response.status_code,
                "success": response.status_code == 200,
            }

            try:
                result["response"] = response.json()
            except json.JSONDecodeError:
                result["response"] = response.text

            return result

        except requests.exceptions.RequestException as e:
            return {
                "status_code": None,
                "success": False,
                "error": str(e)
            }

    def test_connection(self) -> bool:
        """Test API connection with a minimal request.

        Returns:
            True if connection successful
        """
        # Just verify the token is valid
        test_url = "https://api.linkedin.com/v2/me"
        try:
            response = requests.get(
                test_url,
                headers={"Authorization": f"Bearer {self.access_token}"},
                timeout=10
            )
            return response.status_code == 200
        except requests.exceptions.RequestException:
            return False


def main():
    """CLI interface for LinkedIn CAPI."""
    parser = argparse.ArgumentParser(description='LinkedIn Conversions API Client')
    parser.add_argument('--token', required=True, help='LinkedIn access token')
    parser.add_argument('--account', required=True, help='LinkedIn Ads account ID')
    parser.add_argument('--conversion', required=True, help='Conversion ID')
    parser.add_argument('--event-id', required=True, help='Unique event ID')
    parser.add_argument('--email', help='User email')
    parser.add_argument('--phone', help='User phone')
    parser.add_argument('--value', type=float, help='Conversion value')
    parser.add_argument('--currency', default='USD', help='Currency code')
    parser.add_argument('--test', action='store_true', help='Test connection only')

    args = parser.parse_args()

    # Initialize client
    client = LinkedInCAPI(args.token, args.account)

    if args.test:
        print("Testing connection...")
        if client.test_connection():
            print("✅ Connection successful!")
        else:
            print("❌ Connection failed. Check your access token.")
        return

    # Send event
    print(f"Sending conversion event: {args.event_id}")

    result = client.send_event(
        conversion_id=args.conversion,
        event_id=args.event_id,
        email=args.email,
        phone=args.phone,
        value=args.value,
        currency=args.currency
    )

    if result["success"]:
        print(f"✅ Event sent successfully!")
        print(f"   Response: {result.get('response')}")
    else:
        print(f"❌ Event failed!")
        print(f"   Status: {result.get('status_code')}")
        print(f"   Error: {result.get('error') or result.get('response')}")


if __name__ == "__main__":
    main()
