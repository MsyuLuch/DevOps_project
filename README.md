# DevOps_project

Status of Last Deployment: <br>
<img src="https://github.com/MsyuLuch/DevOps_project/actions/workflows/ci-cd-pipeline.yml/badge.svg"><br>

# Проектная работа "DevOps практики и инструменты"

Тема «Создание процесса непрерывной поставки для приложения с применением Практик CI/CD и быстрой обратной связью»

Исходные данные:

        - https://github.com/express42/search_engine_ui - веб-интерфейс поиска слов и фраз на проиндексированных ботом сайтах.

        - https://github.com/express42/search_engine_crawler - поисковый бот для сбора текстовой информации с веб-страниц и ссылок

** Для реализации проекта используем Yandex Cloud


Развернуть приложение можно двумя способами:

        - на виртуальной машине с Docker

        - в Kubernetes cluster

## 1. Разворачиваем виртуальную машину в Yandex Cloud из базового образа, с предустановленным Docker

```
        # создаем ВМ
        infra/terraform/stage$ terraform apply -auto-approve=true
        # разворачиваем приложение
        infra/ansible$ ansible-playbook playbooks/deploy.yml
```

Результат можно увидеть в браузере

```
        http://IP:8000 - UI (основное приложение)
        http://IP:9090 - Prometheus (мониторинг приложения)
        http://IP:5601 - Kibana (логгирование приложения)

```

![ui](https://github.com/MsyuLuch/DevOps_project/blob/main/images/ui-crawler.jpg)
![prometheus](https://github.com/MsyuLuch/DevOps_project/blob/main/images/prometheus.jpg)
![kibana](https://github.com/MsyuLuch/DevOps_project/blob/main/images/kibana.jpg)

## Описание исходного кода

Соберем образы для приложений и загрузим их на DockerHub. Dockerfile находятся в соответствующих директориях (docker/).

`docker/.env.example` - переменные проекта

```
        docker build -t ui:1.0 .
        docker build -t crawler:1.0 .
        docker build -t prometheus:1.0 .
        docker build -t fluentd:2.0 .

        docker push $USER_NAME/ui:1.0
        docker push $USER_NAME/crawler:1.0
        docker push $USER_NAME/prometheus:1.0
        docker push $USER_NAME/fluentd:1.0
```

Проект включает в себя: приложение, мониторинг и логгирование:

```
        # приложение ui + crawler + mongodb + rabbitmq
        docker/docker-compose.yml

        # мониторинг prometheus + node-exporter + mongodb-exporter + blackbox-exporter
        docker/docker-compose-monitoring.yml

        # логгирование fluentd + elasticsearch + kibana
        docker/docker-compose-logging.yml
```

С помощью Packer собираем базовый образ виртуальной машины, с предустановленным Docker

```
        packer build -var-file=infra/packer/variables.hcl infra/packer/docker-base.pkr.hcl
```

Playbook устанавливает Docker, DockerCompose `infra/ansible/playbooks/packer_docker.yml`:

```
        - name: Install Docker Module for Python
        pip:
        name: docker

        - name: Install docker-compose
        pip:
        name: "docker-compose"
        state: "present"
```

Playbook скачивает образы приложений с DockerHub и разворавивает в Docker `infra/ansible/playbooks/deploy.yml`:

```
        - name: Run docker-compose
        docker_compose:
        project_src: /etc/docker/
        files:
        - /etc/docker/docker-compose-logging.yml

        - name: Run docker-compose
        docker_compose:
        project_src: /etc/docker/
        files:
        - /etc/docker/docker-compose.yml

        - name: Run docker-compose
        docker_compose:
        project_src: /etc/docker/
        files:
        - /etc/docker/docker-compose-monitoring.yml
```
--------------------------------------------------------------------------

## 2. Разворачиваем Kubernetes Cluster в Yandex Cloud

Cоздаем кластер

```
        kubernetes/terraform/stage/$ terraform apply -auto-approve=true
```

Устанавливаем локально HELM

```
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
        chmod 700 get_helm.sh
        ./get_helm.sh
```

Устанавливаем NGINX INGRESS

```
        helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace
```

Разворачиваем приложение:

```
        # Создаем новый namespace
        kubectl apply -f kubernetes/crawler/ns.yml

        # Создаем PV, PVC
        kubectl apply -f crawler/pv.yaml -n dev
        kubectl apply -f crawler/pvc.yaml -n dev
```

        2.1 Приложение можно развернуть, используя описания deployment, service (kubernetes/crawler/app)

```
            kubectl apply -f crawler/app/ -n dev
```
        2.2 Приложение можно развернуть, используя helm charts (kubernetes/helm-charts/search-engine)

```
            helm install search-engine-test helm-charts/search-engine/ -n dev --values=helm-charts/search-engine/values.yaml

            helm upgrade search-engine-test helm-charts/ -n dev

            helm del search-engine-test -n dev
```

![helm-ui](https://github.com/MsyuLuch/DevOps_project/blob/main/images/helm-ui-crawler.jpg)

Разворачиваем мониторинг и логирование с импользованием HELM

```
        # Добавляем новые репозитории
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm repo add grafana https://grafana.github.io/helm-charts

        # Обновляем
        helm repo update

        # Создаем новый namespace
        kubectl apply -f monitoring/ns.yaml

        # Устанавливаем стек Prometheus + Alertmanager + Grafana
        helm upgrade --install prometheus prometheus-community/kube-prometheus-stack --namespace=monitoring --values=monitoring/kube-prom-stack.yaml

        # Устанавливаем Promtail
        helm upgrade --install promtail grafana/promtail --namespace=monitoring --values=monitoring/promtail.yaml

        # Устанавливаем Loki
        helm upgrade --install loki grafana/loki-distributed --namespace=monitoring --values=monitoring/loki-distributed.yaml
```

Добавляем правила в INGRESS

```
        kubectl apply -f monitoring/ingress-prometheus.yaml -n monitoring
        kubectl apply -f monitoring/ingress-grafana.yaml -n monitoring
        kubectl apply -f monitoring/ingress-alertmanager.yaml -n monitoring

```

![helm-prometheus](https://github.com/MsyuLuch/DevOps_project/blob/main/images/helm-prometheus.jpg)
![helm-loki](https://github.com/MsyuLuch/DevOps_project/blob/main/images/loki.jpg)

Чтобы увидеть результат можно добавить в локальный hosts ссылки на проект:

```
        IP-NGINX_INGRESS prometheus.search-engine alertmanager.search-engine grafana.search-engine
```

в браузере

```
        http://IP-NGINX_INGRESS - UI (основное приложение)
        http://prometheus.search-engine - Prometheus (мониторинг приложения)
        http://alertmanager.search-engine - Alertmanager (мониторинг приложения)
        http://grafana.search-engine - Grafana (для просмотра логов можно добавить дашборд id=13186)

```

Разворачиваем GITLAB с импользованием HELM:

```
        # Создаем новый namespace
        kubectl apply -f gitlab_ci/ns.yaml

        # Устанавливаем GITLAB
        helm upgrade --install gitlab gitlab/gitlab --namespace=gitlab --values=gitlab_ci/values-gitlab.yaml

        # Узнаем IP адрес GITLAB
        kubectl get ingress -lrelease=gitlab -n gitlab

        # Получаем пароль для доступа к GITLAB
        kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' -n gitlab | base64 --decode ; echo

        # Создаем секрет с регистрационным токеном для Runner
        kubectl apply -f gitlab_ci/gitlab-runner-secret.yaml -n gitlab

        # Устанавливаем GITLAB Runner
        helm install gitlab-runner gitlab/gitlab-runner -f gitlab_ci/values-gitlab-runner.yaml --namespace gitlab

        # Удаляем GITLAB
        helm delete gitlab --namespace=gitlab
        helm delete gitlab-runner --namespace=gitlab
        kubectl delete -f gitlab_ci/ns.yaml
```
![helm-gitlab-runner](https://github.com/MsyuLuch/DevOps_project/blob/main/images/gitlab-runner.jpg)
