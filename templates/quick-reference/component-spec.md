# Quick Reference: Component Spec

One-page fill-in-the-blank component specification.

---

## Component: `[ComponentName]`
**Location**: `src/components/[path]/[ComponentName].tsx`
**Status**: [Planning | In Progress | Review | Complete]

---

## Purpose
[1-2 sentence description]

---

## User Stories (P1 only)
- [ ] As [user], I want [action] so that [benefit]
- [ ] As [user], I want [action] so that [benefit]

---

## Props
```typescript
interface [ComponentName]Props {
  [propName]: [PropType];  // [Description]
  [optional]?: [Type];     // [Description] - defaults to [value]
  on[Event]?: (data: [Type]) => void;  // Called when [event]
}
```

---

## Component Structure
```
<ComponentName>
  ├── <[SubComponent1]>
  └── <[SubComponent2]>
```

---

## State Management
- **Internal**: [state variables and their purpose]
- **External**: [Context/Redux/URL state used]
- **Side Effects**: [useEffect purposes]

---

## Accessibility
- [ ] Keyboard navigation (Tab, Enter, Space)
- [ ] ARIA labels: `aria-label="[label]"`
- [ ] Focus management
- [ ] Screen reader tested

---

## Success Criteria
- [ ] All P1 user stories complete
- [ ] Tests ≥ 80% coverage
- [ ] Build + Lint + Type check pass
- [ ] Lighthouse Accessibility ≥ 90
- [ ] Works in all target browsers

---

**For complete template, see:** [frontend-component-spec.md](../frontend-component-spec.md)
