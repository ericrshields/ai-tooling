# Secrets Keeper UI - Requirements Document

**Version**: 1.2
**Date**: 2026-01-22
**Author**: Product Management Team

---

## Product Requirements

### User Stories

#### Epic 1: Secret Keeper Management

**US-1.1**: As an admin, I want to view all configured secret keepers so I can see which backends are available.

**Acceptance Criteria**:
- List shows keeper name, type, and status
- Empty state displayed when no keepers configured
- List updates when keepers are added/removed

**US-1.2**: As an admin, I want to add a new secret keeper so I can integrate with external secret storage.

**Acceptance Criteria**:
- Form supports AWS Secrets Manager, Azure Key Vault, and HashiCorp Vault
- All required fields are validated
- Success message shown after keeper created
- New keeper appears in list immediately

**US-1.3**: As an admin, I want to test a keeper connection so I can verify it's configured correctly.

**Acceptance Criteria**:
- Test button available on keeper form and in list
- Test result shows success or specific error message
- Test does not save keeper (if testing during creation)
- Test completes in <5 seconds

**US-1.4**: As an admin, I want to edit an existing keeper so I can update credentials or settings.

**Acceptance Criteria**:
- Edit form pre-populated with current values
- Credentials can be updated
- Changes saved with confirmation
- Keeper status re-tested after update

**US-1.5**: As an admin, I want to delete a keeper so I can remove backends I no longer use.

**Acceptance Criteria**:
- Confirmation dialog before deletion
- Cannot delete active keeper (error shown)
- Keeper removed from list after deletion
- Deletion is permanent (no undo)

---

## Functional Requirements

### FR-1: Keeper Types

The system MUST support the following keeper types:

1. **AWS Secrets Manager**
   - Required fields: Region, Access Key ID, Secret Access Key, External ID
   - Optional fields: Role ARN, Session Name

2. **Azure Key Vault**
   - Required fields: Vault URL, Tenant ID, Client ID, Client Secret
   - Optional fields: Subscription ID

3. **HashiCorp Vault**
   - Required fields: Vault Address, Token
   - Optional fields: Namespace, Mount Path

### FR-2: API Integration

**Endpoint Structure**: `/api/v1/secrets-keepers/*`

**API Operations**:
- `GET /api/v1/secrets-keepers` - List keepers
- `POST /api/v1/secrets-keepers` - Create keeper
- `PUT /api/v1/secrets-keepers/{uid}` - Update keeper
- `DELETE /api/v1/secrets-keepers/{uid}` - Delete keeper
- `POST /api/v1/secrets-keepers/{uid}/validate` - Validate keeper

**Note**: Backend team confirmed endpoint prefix is `/api/v1/secrets-keepers` (not `/api/secrets/keepers`).

### FR-3: Active Keeper

The system MUST maintain exactly one "active" keeper:
- Active keeper is the default for new secret references
- Only one keeper can be active at a time
- Setting a keeper as active deactivates others
- Active keeper cannot be deleted

### FR-4: Validation

The system MUST validate keeper configuration:
- Required fields present and non-empty
- Credentials format valid (e.g., valid AWS access key format)
- Connection test successful before saving
- Duplicate keeper names prevented

### FR-5: Error Handling

The system SHOULD provide clear error messages for:
- Invalid credentials: "Unable to authenticate with [keeper type]"
- Network errors: "Cannot connect to [keeper type] - check network and firewall"
- Permission errors: "Insufficient permissions to access [keeper type]"
- Timeout errors: "Connection to [keeper type] timed out"

---

## Non-Functional Requirements

### NFR-1: Performance

- Keeper list MUST load in <2 seconds
- Connection test MUST complete in <5 seconds
- Form interactions MUST feel instant (<100ms feedback)
- Bundle size SHOULD be <100KB for secrets keeper feature

### NFR-2: Security

- Credentials MUST NOT be logged
- API requests MUST use HTTPS
- Credentials MUST be encrypted at rest (backend responsibility)
- RBAC checks MUST enforce admin-only access

### NFR-3: Accessibility

- Keyboard navigation MUST work (Tab, Enter, Esc)
- Screen reader support MUST be complete
- WCAG 2.1 AA compliance MUST be met
- Color contrast MUST be 4.5:1 for text, 3:1 for UI elements

### NFR-4: Browser Support

- Chrome 90+ (MUST support)
- Firefox 88+ (MUST support)
- Safari 14+ (MUST support)
- Edge 90+ (SHOULD support)

---

## UI/UX Requirements

### Component Library

**Requirement**: Use modern, accessible components from shadcn/ui where @grafana/ui lacks needed components.

**Rationale**: shadcn/ui provides high-quality accessible components with better TypeScript support and modern design patterns.

**Implementation**:
- Primary: @grafana/ui for Grafana-specific components (Page, Card, Button)
- Secondary: shadcn/ui for forms, dialogs, and complex interactions
- Custom: Build custom components only when necessary

### Feature Flag

**Name**: `secretsKeeper`
**Default**: Enabled (feature ready for general availability)
**Configuration**: `grafana.ini` section `[feature_toggles]`

### Navigation

The Secrets Keeper page MUST be accessible from:
1. Configuration menu → Secrets Keepers
2. Direct URL: `/admin/secrets-keepers`

### Empty State

When no keepers configured, MUST show:
- Illustration or icon
- Text: "No secret keepers configured"
- Call-to-action button: "Add secret keeper"

---

## Test Requirements

### Test Coverage

- Unit tests MUST cover all components (min 80% coverage)
- Integration tests MUST cover API interactions
- E2E tests MUST cover critical paths:
  - Create AWS keeper
  - Test keeper connection
  - Delete keeper

### Test Data

Backend team will provide test keeper credentials for:
- AWS (test account)
- Azure (test tenant)
- Vault (local dev instance)

---

## Dependencies

### Backend Dependencies

- Backend API MUST be complete before frontend implementation starts
- Backend MUST provide OpenAPI spec for endpoints
- Backend MUST provide test environment

### Design Dependencies

- Final mockups MUST be approved before implementation
- Design system components MUST be available in @grafana/ui
- Accessibility audit MUST be completed on mockups

---

## Open Questions

1. **Namespace Handling**: How should the system handle Vault namespaces? Enterprise-only feature?

2. **External ID Generation**: Confirm where AWS External ID is generated (backend vs frontend).

3. **Migration Path**: How to migrate existing secret keepers (if any) to new UI?

---

## Success Metrics

### Launch Metrics (P0)

- Keeper creation success rate >95%
- Connection test success rate >90% (for valid configs)
- Zero customer-reported security issues

### Usage Metrics (P1)

- % of customers using Secrets Keeper feature
- Average number of keepers per instance
- Most common keeper type (AWS vs Azure vs Vault)

### Quality Metrics (P1)

- Lighthouse accessibility score >90
- Bundle size <100KB
- Page load time <2 seconds
- Zero production bugs in first 2 weeks
