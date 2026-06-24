# Introducing Fluxion: TypeScript State Management That Gets Out of Your Way

State management has a reputation for being complicated. You reach for a solution and suddenly you're writing boilerplate, learning new abstractions, and debugging problems that have nothing to do with your product. Fluxion is a new TypeScript-first state management library built around a single idea: your state should be predictable, and working with it should feel natural.

Fluxion is fully typed from day one. Every state shape, action, and selector is inferred automatically, so your editor catches mistakes before your users do. The library weighs under 3kb gzipped, has no required dependencies, and runs anywhere TypeScript does: React, Vue, Node.js, or a plain browser script. Async flows are a first-class feature, not an add-on bolted to a synchronous core.

The library fits a wide range of real-world needs. Use it to cache server-fetched data, coordinate state between unrelated components, track multi-step form progress, or manage complex client-side workflows. Stores can be scoped to a single component or shared globally, and there is no prescribed folder structure or naming convention you are required to follow.

Getting started takes a single install:

```bash
npm install fluxion
```

```typescript
import { createStore } from 'fluxion';

const counter = createStore({ count: 0 });
counter.set(state => ({ count: state.count + 1 }));
console.log(counter.get().count); // 1
```

From there, the docs cover selectors, subscriptions, middleware, and async actions. If your current state solution feels heavier than the problem it is solving, Fluxion is worth a closer look.
