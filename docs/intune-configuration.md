# Post-deployment checklist

[← Documentation home](index.md)

A condensed checklist of the manual steps after `terraform apply`. Each step links to its detailed page.

- [ ] **1. Connect** to each VM with RDP as `.\labadmin` — [Setup guide → Step 7](setup-guide.md#step-7-connect-with-rdp)
- [ ] **2. Prepare the tenant** (MDM user scope, test user, device group) — [Device enrollment → Prepare the tenant](device-enrollment.md#prepare-the-tenant)
- [ ] **3. Entra join and enroll** each VM with the test user — [Device enrollment → Enroll each VM](device-enrollment.md#enroll-each-vm)
- [ ] **4. Confirm** both devices appear in Entra ID and Intune and have checked in — [Validation → Stage 2](validation-and-testing.md#stage-2-enrollment)
- [ ] **5. Create and assign** the Windows compliance policy — [Compliance policies → Create and assign](compliance-policies.md#create-and-assign-the-policy)
- [ ] **6. Verify** both devices are Compliant — [Validation → Stage 4](validation-and-testing.md#stage-4-compliance-evaluation)
- [ ] **7. Drive CLIENT-02 noncompliant** with `Set-Client02LabState.ps1 -Action Apply` — [CLIENT-02 lab script](client02-lab-script.md)
- [ ] **8. Create the Conditional Access policy** in Report-only, scoped to the test user, excluding emergency access accounts — [Conditional Access](conditional-access.md#create-the-policy-report-only)
- [ ] **9. Review sign-in logs** and the Report-only result from each VM — [Conditional Access → Read the results](conditional-access.md#read-the-results)
- [ ] **10. Restore CLIENT-02** and confirm recovery — [Validation → Stage 5](validation-and-testing.md#stage-5-drift-and-recovery)
- [ ] **11. Clean up** tenant objects and destroy Azure resources — [Lab scenarios → Cleanup](lab-scenarios.md#scenario-6-cleanup)

> [!NOTE]
> A local-account RDP sign-in to an Azure VM does not prove device-based Conditional Access for Microsoft 365. RDP to the VM and sign-ins to cloud apps **from** the VM are separate scenarios. See [Conditional Access](conditional-access.md).
