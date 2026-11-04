# Documentation images

[← Documentation home](../index.md)

This folder holds screenshots for the documentation. **No screenshots are included yet.** The docs mark each place a screenshot would help with a placeholder. Add real, redacted captures from your own lab run. Never add mock-ups or images from other sources.

## Capture list

| # | Suggested file name | What to capture | Used in |
|---|---|---|---|
| 1 | `01-terraform-output.png` | `terraform output` after apply, with public IPs redacted | [Setup guide](../setup-guide.md) |
| 2 | `02-access-work-or-school-connected.png` | **Settings → Accounts → Access work or school** showing "Connected to YOUR_TENANT_DOMAIN's Azure AD" | [Device enrollment](../device-enrollment.md) |
| 3 | `03-compliance-policy-summary.png` | Review page of `CP-Win-IntuneLab-Baseline` | [Compliance policies](../compliance-policies.md) |
| 4 | `04-ca-policy-summary.png` | `CA-IntuneLab-RequireCompliantDevice-ReportOnly` settings, Report-only state | [Conditional Access](../conditional-access.md) |
| 5 | `05-signin-log-report-only-failure.png` | Sign-in log entry from CLIENT-02 → **Report-only** tab → *Report-only: Failure* | [Conditional Access](../conditional-access.md) |
| 6 | `06-client02-firewall-not-compliant.png` | CLIENT-02 → Device compliance → per-setting status showing **Firewall: Not compliant** | [Validation and testing](../validation-and-testing.md) |

## Conventions

- Format: PNG, cropped to the relevant area, width ≤ 1600 px.
- Names: `NN-short-description.png`, lowercase, with hyphens.
- **Redact before committing**: tenant name and ID, UPNs and emails, device and object IDs, correlation and request IDs, subscription IDs, and public IP addresses.
- Embed with descriptive alt text, for example `![CLIENT-02 Firewall setting shown as Not compliant](images/06-client02-firewall-not-compliant.png)`.
- When you add an image, replace the matching placeholder in the doc page.
