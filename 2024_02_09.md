# Integra 09.02.2024

## Themen

1. Deployment SonarQube

```
https://github.com/SonarSource/helm-chart-sonarqube/tree/master/charts/sonarqube

helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
kubectl create namespace sonarqube
helm upgrade --install -n sonarqube sonarqube sonarqube/sonarqube

# NodePort setzen
k -n sonarqube edit svc sonarqube-sonarqube

```


## Demo Application SpringBoot


https://start.spring.io/

https://start.spring.io/#!type=maven-project&language=java&platformVersion=3.2.2&packaging=jar&jvmVersion=17&groupId=de.integra&artifactId=spring-boot-k8s&name=spring-boot-k8s&description=Demo%20project%20for%20Integra&packageName=de.integra.spring-boot-k8s&dependencies=web

Generate => spring-boot-k8s.zip
Unzip 


SpringBootK8sApplication.java
```
package de.integra.springbootk8s;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@SpringBootApplication
public class SpringBootK8sApplication {

    @RequestMapping("/")
        public String home() {
                return "Hello Integra!";
        }

	public static void main(String[] args) {
		SpringApplication.run(SpringBootK8sApplication.class, args);
	}

}
```

# Build

./mvnw package

# Erster Test
```
java -jar target/spring-boot-k8s-0.0.1-SNAPSHOT.jar

http://localhost:8080/

```


## Image erzeugen

vi Dockerfile
```
FROM eclipse-temurin:17-jdk-focal

WORKDIR /app

COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline

COPY src ./src

CMD ["./mvnw", "spring-boot:run"]
```

# Im Bootstrap Verzeichnis 
docker build --platform linux/amd64 -t spring-hellointegra .

# Container starten

```
docker run -p 8080:8080 -t spring-hellointegra
```

http://localhost:8080





# Image in einem Repository zB. Docker Hub bereitstellen (Besser privates Artefactory oder Nexus)

```
docker login --username=softxpert
docker tag 31d5c90a5f86 softxpert/spring-hellointegra:latest

docker push softxpert/spring-hellointegra:latest
```


# Helm Chart erstellen

```
helm create hellointegra
```

cd hellointegra
vi values.yaml
```
image:
  repository: docker.io/softxpert/spring-hellointegra
  pullPolicy: IfNotPresent
  tag: "latest"
```

```
k create ns hellointegra
helm upgrade --install -n hellointegra hellointegra .


k -n hellointegra edit svc hellointegra

# Oder vorher in der values Datei
service:
  type: NodePort
  port: 8080

http://192.168.191.11:32499
```


