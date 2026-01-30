# Implementation Plan: Secrets Keeper UI (Draft)

**Created**: 2026-01-20
**Status**: Draft (awaiting approval)
**Author**: Engineering Team

---

## Overview

Implement the Secrets Keeper UI feature to allow admins to manage external secret storage backends from Grafana.

---

## Phase 1: Foundation

### Step 1.1: Setup Feature Structure

Create directory structure:
```
public/app/features/secrets/
├── api/
│   └── secretsKeeperApi.ts
├── components/
│   ├── KeeperList.tsx
│   ├── KeeperForm.tsx
│   └── KeeperCard.tsx
├── pages/
│   └── SecretsKeeperPage.tsx
├── types/
│   └── keeper.ts
└── utils/
    └── validation.ts
```

### Step 1.2: Define TypeScript Types

Create types in `types/keeper.ts`:
```typescript
export type KeeperType = 'aws' | 'azure' | 'vault'
export type KeeperStatus = 'active' | 'inactive' | 'error'

export interface Keeper {
  uid: string
  name: string
  type: KeeperType
  status: KeeperStatus
  createdAt: string
  updatedAt: string
}

export interface AWSKeeperConfig {
  region: string
  accessKeyId: string
  secretAccessKey: string
  externalId: string
  roleArn?: string
}
```

### Step 1.3: Create RTK Query API Slice

Implement API client using RTK Query.

---

## Phase 2: List View

### Step 2.1: Implement KeeperList Component

**Component**: `KeeperList.tsx`

**Responsibilities**:
- Fetch and display all keepers
- Show empty state when no keepers
- Handle loading and error states
- Provide actions (edit, delete, test)

**Component Library**: Use @grafana/ui components:
- `Page` for layout
- `Card` for keeper items
- `Button` for actions
- `LoadingPlaceholder` for loading state

### Step 2.2: Implement KeeperCard Component

**Component**: `KeeperCard.tsx`

**Display**:
- Keeper name and type
- Status badge (active, inactive, error)
- Last tested timestamp
- Action buttons (edit, delete, test)

---

## Phase 3: Creation Form

### Step 3.1: Implement KeeperForm Component

**Component**: `KeeperForm.tsx`

**Features**:
- Type selector (AWS, Azure, Vault)
- Dynamic form fields based on type
- Form validation
- Test connection button
- Submit handler

**Component Library**: Consider shadcn/ui for form components:
- Better TypeScript support
- Modern form patterns (React Hook Form integration)
- Accessible by default

### Step 3.2: Implement Validation Logic

**Validation Rules**:
- Required fields non-empty
- AWS Access Key format: 20 characters, alphanumeric
- Azure URLs well-formed
- Vault addresses include protocol

---

## Phase 4: Connection Testing

### Step 4.1: Implement Test Connection Feature

**Flow**:
1. User clicks "Test Connection" button
2. API call to `/api/secrets/keepers/{uid}/test`
3. Show loading state
4. Display result (success or error)

**Note**: Connection test endpoint confirmed by backend team.

---

## Phase 5: Edit & Delete

### Step 5.1: Implement Edit Functionality

Reuse `KeeperForm` component in edit mode:
- Pre-populate with existing values
- Allow updates to all fields
- Re-test connection after save

### Step 5.2: Implement Delete Functionality

**Flow**:
1. User clicks "Delete" button
2. Show confirmation dialog
3. Check if keeper is active (block if yes)
4. Call DELETE endpoint
5. Remove from list on success

---

## Verification Steps

### Per Phase
- [ ] Unit tests pass (min 80% coverage)
- [ ] TypeScript compiles with no errors
- [ ] Component renders correctly
- [ ] API integration works

### Pre-Launch
- [ ] E2E tests pass (create, test, delete flows)
- [ ] Accessibility audit complete (WCAG AA)
- [ ] Bundle size <100KB verified
- [ ] Browser testing complete (Chrome, Firefox, Safari)
- [ ] Security review complete (no credential logging)

---

## Open Questions

1. **Connection Test Backend**: Confirm backend endpoint for connection testing is implemented.

2. **Active Keeper Logic**: Clarify API for setting a keeper as active - separate endpoint or field in PUT?

3. **External ID Generation**: Where is AWS External ID generated? Frontend or backend?

4. **Enterprise vs OSS**: Should Secrets Keeper UI be Enterprise-only or available in OSS?

5. **Namespace Handling**: How to handle Vault namespaces (Enterprise-only)?

---

## Dependencies

### Backend
- All API endpoints implemented and tested
- OpenAPI spec available
- Test environment accessible

### Design
- Final mockups approved
- Design tokens in @grafana/ui
- Accessibility audit complete

### Infrastructure
- Feature flag system updated
- RBAC checks in place
- Test credentials available

---

## Risks

### Risk 1: Bundle Size
**Concern**: Adding shadcn/ui may increase bundle size beyond 100KB limit.
**Mitigation**: Measure bundle size after each phase, optimize if needed.

### Risk 2: API Changes
**Concern**: Backend API may change during implementation.
**Mitigation**: Agree on API contract upfront, use OpenAPI spec.

### Risk 3: Browser Compatibility
**Concern**: Modern JavaScript may not work on older browsers.
**Mitigation**: Test on minimum supported versions (Chrome 90, Firefox 88, Safari 14).

---

## Next Steps

1. Resolve open questions with backend and product teams
2. Get final mockup approval from design
3. Set up feature flag in config
4. Begin Phase 1 implementation
