# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Which versions are eligible for receiving such patches depends on the CVSS v3.0 Rating:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

Please report security vulnerabilities responsibly by following these steps:

1. **Do not** open a public GitHub issue
2. Email security details to: security@example.com
3. Include:
   - Type of vulnerability
   - Full paths of source file(s) related to the vulnerability
   - Location of the affected source code (tag/branch/commit or direct URL)
   - Step-by-step instructions to reproduce the issue
   - Proof-of-concept or exploit code (if possible)
   - Impact of the issue

## Security Best Practices

### API Keys and Secrets

- **Never commit API keys or secrets** to the repository
- Use environment variables for sensitive configuration
- Rotate keys regularly
- Restrict API keys to specific services and IPs

### Authentication

- Always validate user input
- Use Firebase Authentication for secure user management
- Implement proper session management
- Use HTTPS for all API communications

### Data Protection

- Encrypt sensitive data at rest
- Use secure connections (HTTPS/TLS) for data in transit
- Implement proper access control in Firestore security rules
- Regular security audits of database rules

### Dependencies

- Keep all dependencies up to date
- Regularly review and update packages
- Use `flutter pub outdated` to check for updates
- Avoid using packages with known security vulnerabilities

## Security Checklist

Before deploying to production:

- [ ] All API keys are secured and restricted
- [ ] Firebase security rules are properly configured
- [ ] HTTPS is enforced for all network requests
- [ ] User inputs are validated and sanitized
- [ ] Authentication tokens are securely stored
- [ ] Sensitive data is encrypted
- [ ] Dependencies are up to date
- [ ] Security testing has been performed

## Known Security Considerations

### Firebase

- Configure proper Firestore security rules
- Set up Cloud Storage security rules
- Enable App Check for additional protection
- Use Firebase App Distribution for secure testing

### Google Maps API

- Restrict API keys to specific platforms
- Use referrer restrictions for web
- Monitor API usage for anomalies
- Set up billing alerts

### Payment Information

- Never store credit card details directly
- Use secure payment processors
- Comply with PCI DSS requirements
- Encrypt payment-related data

## Disclosure Policy

- Security issues are addressed promptly
- Patches are released as soon as possible
- Public disclosure occurs after a patch is available
- Credit is given to security researchers (with permission)

## Security Updates

Security updates are released as needed. Subscribe to repository notifications to receive updates about security patches.

---

**Thank you for helping keep Elite Taxi App secure!**
