# Secrets Keeper UI - Design Document

**Version**: 1.0
**Date**: 2026-01-15
**Author**: Product Design Team

---

## Executive Summary

This document outlines the design for the Secrets Keeper UI feature in Grafana. The feature enables users to configure external secret storage backends (AWS Secrets Manager, Azure Key Vault, HashiCorp Vault) and manage secret references from the Grafana UI.

---

## Architecture Decisions

### Component Library

**Decision**: Use @grafana/ui components exclusively for all UI elements.

**Rationale**:
- Maintains consistency with Grafana ecosystem
- Provides pre-built accessible components
- Reduces bundle size vs external libraries
- Team familiarity with @grafana/ui patterns

**Impact**: No external component libraries (Material-UI, Ant Design, etc.) should be used.

### State Management

**Decision**: Use RTK Query for API client and data fetching.

**Rationale**:
- Redux Toolkit already in use in Grafana
- Built-in caching and request deduplication
- TypeScript-first design matches our stack
- Reduces boilerplate vs raw Redux

**Implementation**: Create new API slice at `public/app/features/secrets/api/secretsKeeperApi.ts`

### API Endpoints

**Decision**: All Secrets Keeper endpoints follow pattern `/api/secrets/keepers/*`

**Endpoints**:
- `GET /api/secrets/keepers` - List all configured keepers
- `POST /api/secrets/keepers` - Create new keeper
- `PUT /api/secrets/keepers/{uid}` - Update keeper
- `DELETE /api/secrets/keepers/{uid}` - Delete keeper
- `POST /api/secrets/keepers/{uid}/test` - Test keeper connection

**Rationale**: Consistent with existing Grafana API patterns.

---

## Requirements

### Phase 1: Core Functionality (P1)

1. **MUST display list of configured secret keepers** in the Secrets Keeper page
   - Show keeper type (AWS, Azure, Vault)
   - Show keeper name and status
   - Show which keeper is active

2. **MUST support creating new secret keepers** via creation form
   - AWS Secrets Manager keeper type
   - Azure Key Vault keeper type
   - HashiCorp Vault keeper type

3. **MUST validate keeper configuration** before saving
   - Required fields present
   - Credentials valid
   - Connection test successful

4. **MUST provide connection test** functionality
   - Button to test keeper connection
   - Display test results (success/failure)
   - Show error messages on failure

5. **MUST support editing existing keepers**
   - Update credentials
   - Update keeper name
   - Update configuration settings

6. **MUST support deleting keepers**
   - Confirmation dialog before deletion
   - Prevent deletion of active keeper
   - Clear error message if deletion blocked

### Phase 1: User Experience (P1)

1. **MUST gate feature behind feature flag** named `secretsKeeper`
   - Default: disabled
   - Can be enabled via config

2. **SHOULD provide helpful error messages** for common issues
   - Invalid credentials
   - Network connectivity problems
   - Permission issues

3. **SHOULD show loading states** during API operations
   - Creating keeper
   - Testing connection
   - Deleting keeper

### Phase 2: Advanced Features (P2)

1. **COULD support secret preview** in read-only mode
   - List secrets from keeper
   - Show secret metadata (name, created date)
   - Do not show secret values

2. **COULD support keeper health monitoring**
   - Periodic health checks
   - Status indicators (healthy, degraded, down)
   - Last successful connection timestamp

---

## Constraints

### Technical Constraints

1. **Bundle size MUST be <100KB** for Secrets Keeper feature
   - Use code splitting
   - Lazy load components
   - Avoid large dependencies

2. **Browser compatibility**: Chrome 90+, Firefox 88+, Safari 14+
   - Can use modern JavaScript features
   - Test on minimum supported versions

3. **TypeScript required** for all new code
   - Strict mode enabled
   - No `any` types except where absolutely necessary
   - All props interfaces exported

### Security Constraints

1. **MUST NOT log sensitive data** (credentials, secret values)
   - Sanitize error messages
   - Redact credentials in network logs

2. **MUST use HTTPS** for all API requests
   - No plaintext credential transmission

3. **MUST implement proper RBAC** checks
   - Only admin users can manage keepers
   - Read-only users can view but not modify

---

## Open Questions

1. **External ID Generation**: Where is the External ID for AWS keepers generated? Backend or frontend?

2. **Active Keeper Logic**: What determines which keeper is "active" when multiple are configured?

---

## Design Mockups

[Placeholder for Figma links - to be added by design team]

---

## Accessibility Requirements

1. **MUST be keyboard navigable**
   - Tab order logical
   - Enter/Space activates buttons
   - Escape closes dialogs

2. **MUST support screen readers**
   - ARIA labels on all interactive elements
   - Form validation errors announced
   - Loading states announced

3. **MUST meet WCAG 2.1 AA standards**
   - Color contrast 4.5:1 for text
   - Focus indicators visible
   - No color-only information
