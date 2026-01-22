# Frontend Component Specification Template

Template for specifying React/frontend components with clear requirements, API, and success criteria.

---

## Component Overview

**Component Name**: `ComponentName`
**Location**: `src/components/[path]/ComponentName.tsx`
**Type**: [Presentational | Container | Higher-Order | Hook | Utility]
**Status**: [Planning | In Progress | In Review | Complete]

**Purpose**: [1-2 sentence description of what this component does and why it exists]

**Parent Feature**: [Link to parent feature or ticket]

---

## User Stories

### Priority 1 (P1) - Must Have
Core functionality that must be delivered.

- [ ] **US-1**: As a [user type], I want to [action] so that [benefit]
  - **Acceptance**: [Specific, testable criteria]
  - **Example**: [Concrete example or scenario]

- [ ] **US-2**: As a [user type], I want to [action] so that [benefit]
  - **Acceptance**: [Specific, testable criteria]
  - **Example**: [Concrete example or scenario]

### Priority 2 (P2) - Should Have
Important but not blocking initial delivery.

- [ ] **US-3**: As a [user type], I want to [action] so that [benefit]
  - **Acceptance**: [Specific, testable criteria]
  - **Example**: [Concrete example or scenario]

### Priority 3 (P3) - Nice to Have
Enhancements for future iterations.

- [ ] **US-4**: As a [user type], I want to [action] so that [benefit]
  - **Acceptance**: [Specific, testable criteria]
  - **Example**: [Concrete example or scenario]

---

## Component API

### Props

```typescript
interface ComponentNameProps {
  // Required props
  /** [Description of what this prop does] */
  propName: PropType;

  /** [Description] */
  anotherProp: AnotherType;

  // Optional props
  /** [Description] - defaults to [default value] */
  optionalProp?: OptionalType;

  // Event handlers
  /** Called when [event occurs]. Receives [parameter description] */
  onEvent?: (data: EventData) => void;

  // Styling/customization
  /** Custom CSS class name for [part of component] */
  className?: string;

  /** Override default styles */
  style?: React.CSSProperties;

  // Accessibility
  /** Accessible label for screen readers */
  'aria-label'?: string;
}
```

### Events

| Event Name | Trigger | Payload | Example |
|------------|---------|---------|---------|
| `onEvent` | When [action happens] | `{ field: value }` | User clicks button |
| `onChange` | When [state changes] | `{ newValue: T }` | Input value updates |
| `onError` | When [error occurs] | `{ error: Error }` | API call fails |

### Ref API (if applicable)

```typescript
interface ComponentNameRef {
  /** [Method description] */
  focus: () => void;

  /** [Method description] */
  reset: () => void;
}
```

---

## Component Hierarchy

### File Structure
```
src/components/ComponentName/
├── ComponentName.tsx          # Main component
├── ComponentName.test.tsx     # Unit tests
├── ComponentName.stories.tsx  # Storybook stories (optional)
├── components/                # Sub-components (if complex)
│   ├── SubComponent.tsx
│   └── SubComponent.test.tsx
├── hooks/                     # Custom hooks (if needed)
│   └── useComponentLogic.ts
└── types.ts                   # Type definitions
```

### Component Tree
```
<ComponentName>
  ├── <Header>
  │   └── <Title>
  ├── <Content>
  │   ├── <Section>
  │   └── <Section>
  └── <Footer>
      └── <Actions>
```

### Dependencies
- **Parent Component**: [Component that renders this]
- **Child Components**: [Components this renders]
- **Hooks Used**: [React hooks, custom hooks]
- **External Libraries**: [Any third-party dependencies]

---

## State Management

### Internal State
```typescript
// State managed within component
const [stateName, setStateName] = useState<StateType>(initialValue);
```

| State Variable | Type | Purpose | Initial Value |
|---------------|------|---------|---------------|
| `isOpen` | `boolean` | Controls modal visibility | `false` |
| `selectedId` | `string \| null` | Tracks selected item | `null` |

### External State
- **Context Used**: [Context name, what it provides]
- **Redux Store**: [Slice name, selectors used]
- **URL State**: [Query params, route params]
- **Local Storage**: [Keys, what's persisted]

### Side Effects
```typescript
useEffect(() => {
  // [Description of side effect]
}, [dependencies]);
```

| Effect | Trigger | Purpose | Cleanup? |
|--------|---------|---------|----------|
| Fetch data | Mount | Load initial data | Cancel request |
| Subscribe to events | Mount | Listen for updates | Unsubscribe |

---

## Accessibility Requirements

### WCAG Compliance
- [ ] **Keyboard Navigation**: All interactive elements accessible via Tab, Enter, Space
- [ ] **Screen Reader**: Meaningful ARIA labels, roles, and live regions
- [ ] **Focus Management**: Visible focus indicators, logical focus order
- [ ] **Color Contrast**: Minimum 4.5:1 for text, 3:1 for UI components
- [ ] **Responsive Text**: Readable at 200% zoom
- [ ] **Semantic HTML**: Use semantic elements (button, nav, main, etc.)

### Specific Requirements
- **Role**: `role="[role]"` (if not semantic HTML)
- **Labels**: `aria-label`, `aria-labelledby`
- **State**: `aria-expanded`, `aria-checked`, `aria-selected`
- **Live Regions**: `aria-live="[polite|assertive]"` for dynamic updates
- **Keyboard Shortcuts**: [List any keyboard shortcuts]

### Testing Checklist
- [ ] Navigable with keyboard only
- [ ] Screen reader announces all content correctly
- [ ] Focus visible at all times
- [ ] Color contrast passes WCAG AA
- [ ] Lighthouse accessibility score ≥ 90

---

## Styling Approach

### Strategy
- [ ] CSS Modules
- [ ] Styled Components
- [ ] Tailwind CSS
- [ ] Emotion
- [ ] Plain CSS/SCSS

### Theme Integration
```typescript
// How component uses theme
const theme = useTheme();
const styles = {
  color: theme.colors.primary,
  spacing: theme.spacing.medium
};
```

### Responsive Breakpoints
| Breakpoint | Width | Layout Changes |
|------------|-------|----------------|
| Mobile | < 640px | [Description] |
| Tablet | 640px - 1024px | [Description] |
| Desktop | > 1024px | [Description] |

---

## Performance Considerations

### Optimization Techniques
- [ ] `React.memo()` for expensive renders
- [ ] `useMemo()` for expensive computations
- [ ] `useCallback()` for stable function references
- [ ] Code splitting with `React.lazy()`
- [ ] Virtual scrolling for long lists
- [ ] Debounce/throttle for frequent events

### Bundle Impact
- **Estimated Size**: [X KB gzipped]
- **Dependencies Added**: [List new dependencies and their sizes]
- **Code Split**: [Yes/No, strategy if yes]

### Render Performance
- **Max Re-renders**: [Number] per user interaction
- **Target Frame Rate**: 60 FPS for animations
- **Largest Contentful Paint**: < 2.5s

---

## Testing Strategy

### Unit Tests
```typescript
describe('ComponentName', () => {
  it('should [behavior]', () => {
    // Arrange, Act, Assert
  });
});
```

**Test Cases**:
- [ ] Renders with required props
- [ ] Handles optional props correctly
- [ ] Calls event handlers with correct data
- [ ] Updates on prop changes
- [ ] Handles error states
- [ ] Accessible with keyboard
- [ ] Screen reader compatible

### Integration Tests
- [ ] Integrates with parent component correctly
- [ ] Communicates with context/store correctly
- [ ] Handles API responses correctly

### E2E Tests (if applicable)
- [ ] Critical user flow: [Description]
- [ ] Edge case: [Description]

### Coverage Target
- **Minimum**: 80% line coverage
- **Focus**: All user interactions, error handling, edge cases

---

## Success Criteria

### Functional Requirements
- [ ] All P1 user stories implemented
- [ ] All props work as specified
- [ ] All events fire correctly
- [ ] Error states handled gracefully

### Quality Requirements
- [ ] TypeScript: No type errors
- [ ] Linting: No errors or warnings
- [ ] Tests: ≥ 80% coverage, all passing
- [ ] Build: Compiles without errors

### Performance Requirements
- [ ] Lighthouse Performance: ≥ 90
- [ ] Lighthouse Accessibility: ≥ 90
- [ ] Bundle size: Within estimate
- [ ] Renders in < 100ms

### Browser Compatibility
- [ ] Chrome (latest 2 versions)
- [ ] Firefox (latest 2 versions)
- [ ] Safari (latest 2 versions)
- [ ] Edge (latest 2 versions)
- [ ] Mobile Safari (iOS 14+)
- [ ] Chrome Mobile (latest)

### Code Review Checklist
- [ ] Follows project coding standards
- [ ] No security vulnerabilities (XSS, injection, etc.)
- [ ] Error handling comprehensive
- [ ] Logging/observability adequate
- [ ] Documentation complete

---

## Open Questions

Track unresolved decisions:

1. **Question**: [What needs to be decided?]
   - **Options**: [A, B, C]
   - **Decision**: [TBD / Chosen option]
   - **Rationale**: [Why this option]

2. **Question**: [What needs to be decided?]
   - **Options**: [A, B, C]
   - **Decision**: [TBD / Chosen option]
   - **Rationale**: [Why this option]

---

## Implementation Notes

### Technical Debt
- [Known limitation or shortcut taken]
- [Reason for debt]
- [Plan to address]

### Future Enhancements
- [Enhancement idea 1]
- [Enhancement idea 2]

### Dependencies on Other Work
- [Blocked by ticket/component X]
- [Blocks ticket/component Y]

---

## Changelog

| Date | Author | Change |
|------|--------|--------|
| YYYY-MM-DD | [Name] | Initial specification |
| YYYY-MM-DD | [Name] | Updated API based on review feedback |

---

**Template Version**: 1.0.0 | **Created**: 2026-01-16

**Related Documentation**:
- [frontend-workflow-config.yml](frontend-workflow-config.yml) - Development workflow
- [agent-instruction-patterns.md](agent-instruction-patterns.md) - Instruction patterns
- [coding-principles.md](../instructions/coding-principles.md) - Coding standards
