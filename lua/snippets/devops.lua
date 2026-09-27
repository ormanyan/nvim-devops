-- LuaSnip snippets for DevOps files (loaded from lua/plugins/devops.lua). Type the prefix, then <Tab>.
local ls = require "luasnip"
local s, t, i, fmt = ls.snippet, ls.text_node, ls.insert_node, require("luasnip.extras.fmt").fmt

local yaml = {
  s({ trig = "k8sdeploy", dscr = "Kubernetes Deployment" }, fmt([[
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {name}
  namespace: {ns}
  labels:
    app: {name}
spec:
  replicas: {replicas}
  selector:
    matchLabels:
      app: {name}
  template:
    metadata:
      labels:
        app: {name}
    spec:
      containers:
        - name: {name}
          image: {image}
          ports:
            - containerPort: {port}
          resources:
            requests: {{ cpu: 100m, memory: 128Mi }}
            limits: {{ cpu: 500m, memory: 512Mi }}
]], { name = i(1, "app"), ns = i(2, "default"), replicas = i(3, "2"), image = i(4, "nginx:1.27"), port = i(5, "80") }, { repeat_duplicates = true })),

  s({ trig = "k8ssvc", dscr = "Kubernetes Service" }, fmt([[
apiVersion: v1
kind: Service
metadata:
  name: {name}
  namespace: {ns}
spec:
  type: {type}
  selector:
    app: {name}
  ports:
    - port: {port}
      targetPort: {tport}
]], { name = i(1, "app"), ns = i(2, "default"), type = i(3, "ClusterIP"), port = i(4, "80"), tport = i(5, "8080") }, { repeat_duplicates = true })),

  s({ trig = "k8sing", dscr = "Kubernetes Ingress" }, fmt([[
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {name}
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
spec:
  ingressClassName: nginx
  tls:
    - hosts: [{host}]
      secretName: {name}-tls
  rules:
    - host: {host}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {svc}
                port:
                  number: {port}
]], { name = i(1, "app"), host = i(2, "app.example.com"), svc = i(3, "app"), port = i(4, "80") }, { repeat_duplicates = true })),

  s({ trig = "k8scm", dscr = "Kubernetes ConfigMap" }, fmt([[
apiVersion: v1
kind: ConfigMap
metadata:
  name: {name}
data:
  {key}: {val}
]], { name = i(1, "config"), key = i(2, "KEY"), val = i(3, "value") })),

  s({ trig = "k8ssecret", dscr = "Kubernetes Secret (stringData)" }, fmt([[
apiVersion: v1
kind: Secret
metadata:
  name: {name}
type: Opaque
stringData:
  {key}: {val}
]], { name = i(1, "secret"), key = i(2, "password"), val = i(3, "change-me") })),

  s({ trig = "compose", dscr = "docker-compose service" }, fmt([[
services:
  {name}:
    image: {image}
    container_name: {name}
    restart: unless-stopped
    ports:
      - "{hport}:{cport}"
    environment:
      - TZ=Europe/Yerevan
    volumes:
      - ./data:/data
    networks: [backend]

networks:
  backend:
]], { name = i(1, "app"), image = i(2, "nginx:alpine"), hport = i(3, "8080"), cport = i(4, "80") }, { repeat_duplicates = true })),

  s({ trig = "ghjob", dscr = "GitHub Actions workflow" }, fmt([[
name: {name}
on:
  push:
    branches: [main]
  pull_request:

jobs:
  {job}:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: {step}
        run: |
          {cmd}
]], { name = i(1, "CI"), job = i(2, "build"), step = i(3, "Run"), cmd = i(4, "make") })),

  s({ trig = "aplay", dscr = "Ansible playbook skeleton" }, fmt([[
---
- name: {desc}
  hosts: {hosts}
  become: true
  gather_facts: true

  tasks:
    - name: {task}
      ansible.builtin.{mod}:
        {args}
]], { desc = i(1, "Configure hosts"), hosts = i(2, "all"), task = i(3, "Install packages"), mod = i(4, "package"), args = i(5, "name: vim\n        state: present") })),

  s({ trig = "atask", dscr = "Ansible task" }, fmt([[
- name: {name}
  ansible.builtin.{mod}:
    {args}
]], { name = i(1, "Do something"), mod = i(2, "command"), args = i(3, "cmd: echo hi") })),
}

local terraform = {
  s({ trig = "tfres", dscr = "terraform resource" }, fmt([[
resource "{type}" "{name}" {{
  {body}
}}
]], { type = i(1, "aws_instance"), name = i(2, "this"), body = i(3, "") })),
  s({ trig = "tfvar", dscr = "terraform variable" }, fmt([[
variable "{name}" {{
  description = "{desc}"
  type        = {type}
  default     = {def}
}}
]], { name = i(1, "name"), desc = i(2, ""), type = i(3, "string"), def = i(4, "null") })),
  s({ trig = "tfout", dscr = "terraform output" }, fmt([[
output "{name}" {{
  description = "{desc}"
  value       = {val}
}}
]], { name = i(1, "name"), desc = i(2, ""), val = i(3, "") })),
  s({ trig = "tfmod", dscr = "terraform module" }, fmt([[
module "{name}" {{
  source  = "{src}"
  version = "{ver}"

  {body}
}}
]], { name = i(1, "name"), src = i(2, "terraform-aws-modules/vpc/aws"), ver = i(3, "~> 5.0"), body = i(4, "") })),
  s({ trig = "tfbackend", dscr = "terraform s3 backend" }, fmt([[
terraform {{
  required_version = ">= 1.6"
  backend "s3" {{
    bucket         = "{bucket}"
    key            = "{key}"
    region         = "{region}"
    dynamodb_table = "{lock}"
    encrypt        = true
  }}
}}
]], { bucket = i(1, "tf-state"), key = i(2, "env/prod/terraform.tfstate"), region = i(3, "eu-central-1"), lock = i(4, "tf-lock") })),
}

local sh = {
  s({ trig = "#!", dscr = "strict bash header" }, t { "#!/usr/bin/env bash", "set -Eeuo pipefail", "IFS=$'\\n\\t'", "", "" }),
  s({ trig = "log", dscr = "log function" }, t { 'log() { printf "[%s] %s\\n" "$(date +%FT%T)" "$*" >&2; }' }),
  s({ trig = "trap", dscr = "cleanup trap" }, fmt([[
cleanup() {{
  {body}
}}
trap cleanup EXIT
]], { body = i(1, 'rm -rf "$tmpdir"') })),
}

local dockerfile = {
  s({ trig = "dockermulti", dscr = "multi-stage Dockerfile" }, fmt([[
FROM {base} AS build
WORKDIR /src
COPY . .
RUN {build}

FROM {runtime}
WORKDIR /app
COPY --from=build /src/{artifact} .
USER 65532:65532
EXPOSE {port}
ENTRYPOINT ["{entry}"]
]], { base = i(1, "golang:1.23-alpine"), build = i(2, "go build -o app ."), runtime = i(3, "gcr.io/distroless/static"), artifact = i(4, "app"), port = i(5, "8080"), entry = i(6, "/app/app") })),
}

ls.add_snippets("yaml", yaml)
for _, ft in ipairs { "yaml.kubernetes", "yaml.docker-compose", "yaml.github", "yaml.ansible", "yaml.helm-values", "helm" } do
  ls.add_snippets(ft, yaml)
end
ls.add_snippets("terraform", terraform)
ls.add_snippets("sh", sh)
ls.add_snippets("bash", sh)
ls.add_snippets("dockerfile", dockerfile)
