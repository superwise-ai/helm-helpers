# Credit Notice

This chart is heavily inspiried by the original [`incubator/raw`](https://github.com/helm/charts/tree/master/incubator/raw) chart.  
The credit goes to the creators of the original chart.

# Raw Chart

The `raw` chart takes a list of Kubernetes resources and generates a manifest of resources that can be installed using Helm.  
The Kubernetes resources can be "raw" ones defined under the `resources` key, or "templated" ones defined under the `templates` key.  
In addition, each type can be either a slice or a map. A map is useful when working with multiple values files.  
Adding custom labels to all resources is also supported using `commonLabels` and standard chart labels can also be appened to the resources using `appendChartLabels=true` so they can be indentified.

## Installation

```sh
helm repo add helm-helpers https://superwise-ai.github.io/helm-helpers
helm repo update
helm install helm-helpers/raw -n example -f resources.yaml
```

## Values

| Key               | Type           | Default | Description                                                            |
| ----------------- | -------------- | ------- | ---------------------------------------------------------------------- |
| appendChartLabels | bool           | `false` | Append default chart labels to all resources                           |
| commonLabels      | object         | `{}`    | Common labels to add to all resources                                  |
| resources         | list or object |         | A list or an object containing the desired resources                   |
| templates         | list or object |         | A list or an object containing the templates for the desired resources |

## Examples

```
# resources-slice.yaml

resources:
  - apiVersion: scheduling.k8s.io/v1
    description: Used for system critical pods that must not be moved from their current node.
    kind: PriorityClass
    metadata:
      name: system-node-critical
    preemptionPolicy: PreemptLowerPriority
    value: 2000001000
  - apiVersion: v1
    kind: Namespace
    metadata:
      name: example

commonLabels:
  foo: bar
```

```
# resources-map.yaml

resources:
  namespaces:
    - apiVersion: v1
      kind: Namespace
      metadata:
        name: example
  configmaps:
    - apiVersion: v1
      kind: ConfigMap
      metadata:
        name: example

appendChartLabels: true
```

```
# templates-slice.yaml

templates:
  - |
    apiVersion: v1
    kind: Secret
    metadata:
      name: example-secret
    stringData:
      mykey: {{ .Values.exampleValue }}

exampleValue: test
```

```
# templates-map.yaml

templates:
  secrets:
    - |
      apiVersion: v1
      kind: Secret
      metadata:
        name: example-secret
      stringData:
        mykey: {{ .Values.exampleValue }}
  configmaps:
    - |
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: example-cm
      data:
        mykey: {{ .Values.exampleValue }}


exampleValue: test
```
