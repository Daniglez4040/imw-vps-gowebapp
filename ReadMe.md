## Despliegue de la Aplicación

Este tutorial describe cómo desplegar la **Kotlin Web App** en el servidor **una vez que todos los archivos del proyecto ya están presentes en la máquina**.

---

### 1. Acceder al directorio del proyecto

```bash
cd ~/kotlinweb
```

---

### 2. Construir la aplicación

Primero se limpia y compila el proyecto para generar el JAR ejecutable:

```bash
./gradlew clean
./gradlew build
```

Al finalizar, el archivo generado estará disponible en:

```
build/libs/kotlinweb.jar
```

---

### 3. Prueba manual (opcional)

Antes de ejecutar la aplicación como servicio, es recomendable probarla manualmente:

```bash
java -jar build/libs/kotlinweb.jar
```

La aplicación quedará accesible en:

```
http://<IP_DEL_SERVIDOR>:9090
```

Detén la aplicación con `Ctrl + C` una vez verificado su funcionamiento.

---

### 4. Iniciar la aplicación con systemd

Si el servicio `kotlinweb.service` ya está configurado, inicia la aplicación en segundo plano:

```bash
sudo systemctl start kotlinweb
```

Para asegurarte de que se inicie automáticamente al arrancar el servidor:

```bash
sudo systemctl enable kotlinweb
```

---

### 5. Verificar el estado del servicio

Comprueba que la aplicación esté corriendo correctamente:

```bash
sudo systemctl status kotlinweb
```

Si el estado es `active (running)`, la aplicación está desplegada correctamente.

---

### 6. Actualizar la aplicación

Cada vez que se realicen cambios en el código:

```bash
./gradlew build
sudo systemctl restart kotlinweb
```

Esto recompilará la aplicación y reiniciará el servicio con la nueva versión.

---

### 7. Acceso mediante dominio (opcional)

Si el proxy inverso con **Caddy** está configurado, la aplicación podrá accederse mediante HTTPS:

```
https://example.com
```

En este caso, Caddy redirige el tráfico al puerto interno **9090** donde corre la aplicación Kotlin.

---

**Despliegue completado**
La aplicación se ejecuta de forma persistente, segura y lista para producción.
