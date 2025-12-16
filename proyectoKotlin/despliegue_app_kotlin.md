# Kotlin Web App

Este repositorio contiene los pasos y scripts necesarios para desplegar una aplicación web básica escrita en **Kotlin** utilizando el framework **Ktor** en un servidor **VPS con Ubuntu**.

---

## Requisitos Previos

Antes de configurar la aplicación, es necesario instalar **Java**, ya que Kotlin se ejecuta sobre la JVM.

---

## Instalación de Java

### 1. Actualizar el sistema

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Instalar OpenJDK 21

```bash
sudo apt install openjdk-21-jdk -y
```

### 3. Verificar la instalación

```bash
java -version
```

Deberías ver una salida similar a:

```
openjdk version "21.0.8"
```

---

## Configuración y Construcción de la Aplicación

### 1. Preparación del entorno

Crea el directorio de trabajo y la estructura básica del proyecto:

```bash
mkdir kotlinweb
cd kotlinweb
mkdir -p src/main/kotlin
```

---

### 2. Configuración de Gradle

#### `settings.gradle.kts`

Define el nombre del proyecto raíz:

```kotlin
rootProject.name = "kotlinweb"
```

#### `build.gradle.kts`

Este archivo define los plugins, repositorios y dependencias necesarias (Ktor, Netty, HTML, SLF4J), además de configurar la generación de un JAR ejecutable con todas las dependencias incluidas.

```kotlin
plugins {
    kotlin("jvm") version "2.0.21"
    application
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("io.ktor:ktor-server-core-jvm:3.0.0")
    implementation("io.ktor:ktor-server-netty-jvm:3.0.0")
    implementation("io.ktor:ktor-server-html-builder-jvm:3.0.0")
    implementation("org.jetbrains.kotlinx:kotlinx-html-jvm:0.11.0")
    implementation("org.slf4j:slf4j-simple:2.0.16")
}

application {
    mainClass.set("MainKt")
}

tasks.jar {
    manifest {
        attributes["Main-Class"] = "MainKt"
    }
    duplicatesStrategy = DuplicatesStrategy.EXCLUDE
    from({
        configurations.runtimeClasspath.get()
            .filter { it.name.endsWith("jar") }
            .map { zipTree(it) }
    })
}
```

---

### 3. Código de la aplicación

Crea el archivo `src/main/kotlin/Main.kt`.
La aplicación levanta un servidor **Netty** en el puerto **9090** y sirve contenido HTML dinámico.

```kotlin
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.application.*
import io.ktor.server.html.*
import io.ktor.server.routing.*
import kotlinx.html.*
import java.time.LocalDateTime

fun main() {
    embeddedServer(Netty, port = 9090) {
        routing {
            get("/") {
                val clientip = call.request.local.remoteHost
                call.respondHtml {
                    head { title { +"Kotlin Web App" } }
                    body {
                        h1 { +"Aplicación Web con Kotlin" }
                        p { +"Fecha y hora del servidor: ${LocalDateTime.now()}" }
                        p { +"IP del cliente: $clientip" }
                        a("/contacto") { +"Ir a contacto" }
                    }
                }
            }
            // Agrega aquí el resto de rutas (ej. /contacto)
        }
    }.start(wait = true)
}
```

---

## Compilación (Build)

### 1. Generar el wrapper de Gradle

```bash
gradle wrapper
```

> **Opcional:**
> Si la versión de Gradle descargada es antigua, edita
> `gradle/wrapper/gradle-wrapper.properties` y actualiza:
>
> ```
> distributionUrl=https\://services.gradle.org/distributions/gradle-8.10.2-bin.zip
> ```

### 2. Construir el proyecto

```bash
./gradlew clean
./gradlew build
```

El JAR ejecutable se generará en:

```
build/libs/kotlinweb.jar
```

### 3. Ejecución manual

```bash
java -jar build/libs/kotlinweb.jar
```

La aplicación quedará accesible en el puerto **9090**.

---

## Despliegue Automático con systemd

Para ejecutar la aplicación en segundo plano y que se inicie automáticamente al arrancar el servidor, se configura un servicio de **systemd**.

### 1. Crear el servicio

Archivo: `/etc/systemd/system/kotlinweb.service`

```ini
[Unit]
Description=Kotlin Web App (Ktor)
After=network.target

[Service]
Type=simple
User=isard
WorkingDirectory=/home/isard/kotlinweb
ExecStart=/usr/bin/java -jar /home/isard/kotlinweb/build/libs/kotlinweb.jar
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

> ⚠️ **Nota:**
> Asegúrate de cambiar `User`, `WorkingDirectory` y `ExecStart` si tu usuario no es `isard`.

---

### 2. Activar el servicio

```bash
sudo systemctl daemon-reload
sudo systemctl enable kotlinweb
sudo systemctl start kotlinweb
```

### 3. Verificar el estado

```bash
sudo systemctl status kotlinweb
```

La aplicación quedará activa en el puerto **9090**.

---

## Proxy Inverso con Caddy

Si dispones del script de configuración de **Caddy**, puedes exponer la aplicación (puerto 9090) a través de un dominio con **HTTPS**.

### Configuración del proxy inverso

```bash
sudo bash setup_caddy_reverse_proxy example.com 9090 admin@example.com
```

Al acceder a:

```
https://example.com
```

deberías ver la **Kotlin Web App** funcionando correctamente 🚀
