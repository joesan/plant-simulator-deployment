## helm
We are using helm for templating & packaging. We use the standard helm folder structure:

```
├── charts
├── templates
├   ├── base
│   ├    ├── application
│   ├        ├── plant-simulator-deployment.yaml
│   ├        ├── plant-simulator-namespace.yaml
│   ├        └── plant-simulator-service.yaml
│   ├── kustomization.yaml
│   ├    ├── monitoring
│   ├        ├── todo.yaml
│   ├        ├── todo.yaml
│   ├        ├── todo.yaml
│   ├        └── todo.yaml
├   ├── dev
│   ├    ├── flux-patch.yaml
│   ├    └── kustomization.yaml
│   ├── production
├   ├    ├── flux-patch.yaml
└   ├    ├── kustomization.yaml
```