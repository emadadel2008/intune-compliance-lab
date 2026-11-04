# 05 - Conditional Access

[← 04 - Compliance policy](04-compliance-policy.md) · Next: [06 - Validation and troubleshooting](06-validation-and-troubleshooting.md)

Create a Conditional Access policy that requires a compliant device, test it in **Report-only**, and only then consider enforcement. Background: [Conditional Access](conditional-access.md).

> [!WARNING]
> A misconfigured Conditional Access policy can lock users, including admins, out of the tenant. Always start in Report-only, target only the test user, and exclude emergency access accounts.

> [!NOTE]
> Conditional Access controls sign-ins to **cloud apps** from the VMs. It does not control RDP to the VMs with the local `labadmin` account.

## 1. Create the policy in Report-only

Entra admin center → **Protection → Conditional Access → Policies → New policy**.

| Setting | Value |
|---|---|
| Name | `CA-IntuneLab-RequireCompliantDevice-ReportOnly` |
| Users → Include | `YOUR_TEST_USER` |
| Users → Exclude | Emergency access accounts and your admin account |
| Target resources | **Office 365** |
| Conditions → Device platforms | Windows |
| Grant | **Require device to be marked as compliant** |
| Enable policy | **Report-only** |

Optional: preview with **What If** for `YOUR_TEST_USER`, Office 365, and Windows.

## 2. Test from each device

1. Confirm current compliance in Intune (sync first).
2. On `CLIENT-01`, open Microsoft Edge, sign in to the browser profile as `YOUR_TEST_USER`, and go to `https://www.office.com`.
3. Repeat on `CLIENT-02` while it is in the `Apply` state.

The device must be identified to Entra ID. If the sign-in log shows **no Device ID**, the test is invalid. See [Conditional Access → Test from each device](conditional-access.md#test-from-each-device).

## 3. Review sign-in logs

Entra admin center → **Identity → Monitoring & health → Sign-in logs** → filter by `YOUR_TEST_USER` → open each sign-in.

| Sign-in from | Device info → Compliant | Report-only tab |
|---|---|---|
| `CLIENT-01` | Yes | Report-only: Success |
| `CLIENT-02` (after `Apply`) | No | Report-only: Failure |
| `CLIENT-02` (after `Restore` + sync) | Yes | Report-only: Success |

These are expected results; record your actual results with the [evidence log template](validation-and-testing.md#evidence-log-template).

## 4. Enforcement (optional)

Switch the policy from **Report-only** to **On** only after Report-only results match expectations, exclusions are confirmed, and you have tested with the test user only. Enforcement should then block Office 365 sign-in from noncompliant `CLIENT-02`. See [Moving to enforcement](conditional-access.md#moving-to-enforcement). Return the policy to **Report-only** or **Off** when finished.

## Done when

- [ ] The policy exists in Report-only, scoped to the test user, with exclusions.
- [ ] Sign-in logs show Success for `CLIENT-01` and Failure for `CLIENT-02` in the Report-only tab.
