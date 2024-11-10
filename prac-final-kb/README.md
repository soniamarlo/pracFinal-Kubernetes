# **Práctica Final: Kubernetes**
<a name="resources"></a>
# Despliegue de aplicación Flask y MMySQL en Kubernetes con Helm

Índice de contenidos:

- [Descripción](#descripción)
- [Requisitos Previos](#requisitos-previos)
- [Configuración](#configuración)
  - [Variables de Entorno](#variables-de-entorno)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Despliegue de la Aplicación](#despliegue-de-la-aplicación)
  - [Paso 1: Clonar el Repositorio](#paso-1-clonar-el-repositorio)
  - [Paso 2: Crear el Namespace](#paso-2-crear-el-namespace)
  - [Paso 3: Instalación del Chart de Helm](#paso-3-instalación-del-chart-de-helm)
  - [Paso 4: Verificación de Recursos](#paso-4-verificación-de-recursos)
  - [Paso 5: Acceso a la Aplicación](#paso-5-acceso-a-la-aplicación)
  - [Paso 6: Uso de la Aplicación](#paso-6-uso-de-la-aplicación)
- [Documentación de Ingress](#documentación-de-ingress)
- [Escalabilidad Automática (HPA)](#escalabilidad-automática-hpa)
- [Configuración de Persistencia](#configuración-de-persistencia)
- [Minikube Tunnel](#minikube-tunnel)
- [Detener y Eliminar el Despliegue](#detener-y-eliminar-el-despliegue)
- [Advertencias importantes](#advertencias-importantes)

<a name="install-chart"></a>

## **Descripción**

Este proyecto despliega una **aplicación web** de **gestión de adopciones de mascotas** desarrollada en **Flask** con una base de datos **MySQL** en un clúster de **Kubernetes** utilizando **Helm**. El despliegue incluye persistencia de datos, alta disponibilidad y exposición externa de la aplicación mediante Ingress.

La aplicación está configurada para soportar **persistencia de datos, alta disponibilidad y escalabilidad automática**, lo que asegura que los servicios puedan manejar carga adicional y recuperarse de fallos. Además, el acceso externo se maneja mediante **Ingress**.

<a name="requisitos-previos"></a>

## **Requisitos Previos**

- **Kubernetes** (con Minikube para el entorno local)
- **Helm**(para gestionar el despliegue de los charts)

<a name="configuracion"></a>

## **Configuración**
La aplicación Flask y MySQL se configuran a través de **Secrets y ConfigMap** en Kubernetes. En el archivo `values.yaml` se configuran las variables de entorno críticas y los parámetros para el despliegue.

### **Variables de Entorno**

Las variables sensibles, como las contraseñas, se configuran mediante **Secrets de Kubernetes**. A continuación, algunos ejemplos de las configuraciones utilizadas:

- **DB_HOST**: El nombre del servicio MySQL en Kubernetes.
- **DB_PORT**: El puerto en el que MySQL escucha dentro del contenedor.
- **DB_USER**: El nombre de usuario para conectarse a la base de datos.
- **DB_PASSWORD**: La contraseña para el usuario de la base de datos.
- **DB_NAME**: El nombre de la base de datos.

<a name="estructura-del-proyecto"></a>

## **Estructura del Proyecto**
La estructura del proyecto es la siguiente:

prac-final-kb/

├── templates/
│   ├── app-configmap.yaml                    # Configuración de variables de entorno para la aplicación

│   ├── app-deployment.yaml                   # Despliegue de la aplicación Flask 

│   ├── app-hpa.yaml                          # Configuración del autoescalado

│   ├── app-ingress.yaml                      #  Ingress para exponer Flask al exterior

│   ├── app-secret.yaml                       # Secretos para la aplicación Flask

│   ├── mysql-configmap.yaml                  # Configuración de variables de entorno para MySQL

│   ├── mysql-container-service.yaml          # Define el Servicio interno para MySQL

│   ├── mysql-service.yaml                    # Servicios para MySQL

│   └── mysql-statefulset.yaml                # StatefulSet para MySQL

│   └── mysql-deployment.yaml                 # Despliegue de MySQL

│   └── mysql-secret.yaml                     # Secretos para MySQL

├── Chart.yaml                                # Archivo principal del chart de Helm

└── values.yaml                               # Configuraciones generales para el despliegue

<a name="despliegue-de-la-aplicacion"></a>

## **Despliegue de la aplicación**
<a name="paso-1-clonar-el-repositorio"></a>

### Paso 1: Clonar el Repositorio

Primero, clona el repositorio donde está el chart de Helm de la práctica:

```bash
git clone https://github.com/soniamarlo/pracFinal-Kubernetes.git
cd prac-final-kb
```
<a name="paso-2-crear-el-namespace"></a>

### Paso 2: Crear el Namespace

Crea el namespace donde se desplegarán los recursos de Flask y MySQL:
```
kubectl create namespace flask-mysql-kb
```

<a name="paso-3-instalacion-del-chart-de-helm"></a>

### Paso 3: Instalación del Chart de Helm

Despliega la aplicación utilizando Helm en el namespace flask-mysql-kb:
```
helm install flask-mysql-kb ./ --namespace flask-mysql-kb --set mysql.auth.rootPassword="rootpassword" --set mysql.auth.password="rootpassword"

```
Este comando instalará la aplicación Flask y MySQL en el clúster de Kubernetes.

<a name="paso-4-verificacion-de-recursos"></a>

### Paso 4: Verificación de recursos

Para asegurarte de que todos los recursos (pods, servicios, ingress, volúmenes persistentes, etc.) están correctamente desplegados, puedes ejecutar los siguientes comandos:
- **Verificar pods**
```
kubectl get pods -n flask-mysql-kb
```
Esto debería mostrar los pods de Flask y MySQL en estado Running
- **Verificar servicios**
```
kubectl get svc -n flask-mysql-kb
```


<a name="paso-5-acceso-a-la-aplicacion"></a>

### Paso 5: Acceso a la Aplicación

<a name="configuracion-archivo-hosts"></a>

- **Confirguración archivo /etc/hosts**

Configura el archivo /etc/hosts en tu máquina local para que la aplicación sea accesible desde el navegador. Añade la IP de Minikube y el host configurado en Ingress:
```
<minikube ip> flask-app.local
```
<a name="minikube-tunnel"></a>

- **Minikube Tunnel**

Para exponer los servicios de tipo LoadBalancer en Minikube y hacerlos accesibles desde el navegador, es necesario iniciar un túnel de Minikube. Ejecuta el siguiente comando en una terminal con permisos de administrador:
```
minikube tunnel
```
<a name="comprobacion-de-datos"></a>

- **Comprobación de Datos en la Base de Datos**
Para verificar los datos de MySQL desde el contenedor, usa el siguiente comando para acceder al contenedor de MySQL:
```
kubectl exec -it pod/flask-mysql-kb-flask-mysql-kb-mysql-0 -n flask-mysql-kb -- mysql -u root -p
```

Una vez dentro del pod, introduce la contraseña configurada (rootpassword) y luego puedes ejecutar comandos SQL como SHOW TABLES; o SELECT * FROM <tabla>;.


<a name="paso-6-uso-aplicacion></a>

### Paso 6: Uso de la aplicación

<a name="anadir-datos-bbdd></a>

- **Añadir datos en la BBDD**

Para añadir datos a la base de datos de MySQL en la aplicación, utiliza los siguientes comandos curl para interactuar con los endpoints:

### Añadir un Usuario
```bash
curl -X POST http://flask-app.local/usuarios \
-H "Content-Type: application/json" \
-d '{
    "nombre": "Sonia Martin",
    "email": "sonia.martin@example.com",
    "direccion": "Calle Piruleta 004",
    "CP": "28031",
    "localidad": "Madrid"
}'
```

### Añadir un Perro
```bash
curl -X POST http://flask-app.local/perros \
-H "Content-Type: application/json" \
-d '{
    "nombre": "Firulais",
    "raza": "Labrador",
    "idUsuario": 1
}'
```

### Añadir un Historial de Adopciones
```bash
curl -X POST http://flask-app.local/historialAdopciones \
-H "Content-Type: application/json" \
-d '{
    "fecha": "2024-08-22",
    "idUsuario": 1,
    "idPerro": 1
}'
```
<a name="uso></a>

- **Uso de la aplicación**

Una vez que los pods estén en ejecución, la aplicación Flask estará disponible en http://flask-app.local y puedes acceder a los siguientes endpoints:

- **GET /perros**: Obtiene una lista de todos los perros.
- **POST /perros**: Agrega un nuevo perro.
- **GET /usuarios**: Obtiene una lista de todos los usuarios.
- **POST /usuarios**: Agrega un nuevo usuario.
- **GET /historialAdopciones**: Obtiene el historial de adopciones.

<a name="documentacion-de-ingress"></a>

- **Documentación de Ingress**

El acceso externo está gestionado por Ingress, lo que permite enrutar el tráfico desde fuera del clúster hacia el servicio de Flask en el host flask-app.local. La configuración del host se define en values.yaml:
```
app:
  ingress:
    enabled: true
    host: flask-app.local
    path: /
```
- **Verificar ingress**
```
kubectl get ingress -n flask-mysql-kb
```
<a name="escalabilidad-automatica"></a>

- **Escalabilidad Automática(HPA)**

La configuración del autoescalado está habilitada mediante el archivo app-hpa.yaml. La aplicación está configurada para escalar cuando el uso de CPU supera el 70%. Puedes modificar estos parámetros en el archivo values.yaml.
```
autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 5
    targetCPUUtilizationPercentage: 70
```
- **Verificar HPA**
Verifica el estado del autoescalador con el siguiente comando:

```
kubectl get hpa -n flask-mysql-kb
```
<a name="configuracion-de-persistencia"></a>

- **Configuración de Persistencia**

Para asegurar que los datos de MySQL sean persistentes, se configura un Persistent Volume Claim (PVC) en el archivo values.yaml. Puedes ajustar el tamaño del almacenamiento persistente:
```
mysql:
  persistence:
    enabled: true
    size: 1Gi
```
<a name="detener-y-eliminar-el-despliegue"></a>

- **Detener y Eliminar el Despliegue**
Para detener y eliminar el despliegue y todos los recursos asociados, ejecuta:
```
helm uninstall flask-mysql-kb --namespace flask-mysql-kb

```
Esto eliminará el namespace flask-mysql-kb y todos los recursos asociados.

<a name="advertencias></a>

## Advertencias importantes

- **Añadir Usuarios antes de Perros**: Antes de añadir un perro, asegúrate de que haya al menos un usuario creado. Esto es necesario porque los perros están vinculados a usuarios mediante una clave foránea. Si intentas añadir un perro sin un usuario asociado, recibirás un error. Esto garantiza la integridad de los datos.

