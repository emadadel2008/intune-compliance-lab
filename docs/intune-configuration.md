# Post-deployment Intune exercise

1. Connect to each VM using RDP.
2. Sign in with an appropriate Entra test account (not only the local administrator).
3. Join/register the Windows device with the intended Entra tenant using a supported enrollment method.
4. Confirm the device appears in Intune and has checked in.
5. Create and assign a Windows compliance policy.
6. Configure CLIENT-01 to meet the policy and CLIENT-02 to fail it.
7. Verify the compliance state in Intune.
8. Create a Conditional Access policy requiring compliant devices for a selected cloud app.
9. Begin in Report-only mode, test with dedicated accounts, and exclude emergency access accounts.
10. Review sign-in logs and the Conditional Access evaluation.

Do not assume local-account RDP sign-in itself proves device-based Conditional Access for Microsoft 365. RDP sign-in to an Azure VM and access to Microsoft 365 cloud apps are separate sign-in scenarios.
