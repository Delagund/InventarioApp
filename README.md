# inventory_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Inventory Master - macOS Edition 📦

Una solución profesional de gestión de inventarios construida bajo los principios de Clean Architecture y POO. Diseñada específicamente para macOS, con capacidad de escalabilidad multiplataforma y sincronización en la nube en futuras fases.

🚀 Propuesta de Valor
A diferencia de los inventarios tradicionales, esta aplicación permite una separación lógica total mediante una base de datos única, permitiendo asignar productos a múltiples "Espacios" (Hogar, Oficina, Jardín) sin duplicar datos.

🛠 Tech Stack
Lenguaje: Dart + Flutter 

Interfaz: 

Persistencia: Se utiliza estrictamente sqflite_common_ffi para garantizar compatibilidad con macOS Desktop y evitar el error de MissingPlugin.

Arquitectura: Clean Architecture + MVVM

📊 Diseño de Arquitectura
1. Modelo Entidad-Relación (Base de Datos)
Este diagrama muestra cómo gestionamos la relación muchos-a-muchos entre productos y categorías para lograr la separación lógica.

```mermaid
erDiagram
    PRODUCT ||--o{ PRODUCT_CATEGORY : "asignado a"
    CATEGORY ||--o{ PRODUCT_CATEGORY : "contiene"
    
    PRODUCT {
        int id PK
        string sku UK "Código Interno"
        string name
        string barcode
        int quantity
        string description
        string image_path
        datetime created_at
    }
    
    CATEGORY {
        int id PK
        string name UK
        string description
    }
    
    PRODUCT_CATEGORY {
        int product_id FK
        int category_id FK
    }

```
2. Casos de Uso (Alcance MVP)
El MVP se centra en el ciclo de vida del producto y su organización básica en un periodo de 2 a 4 semanas.

```mermaid
flowchart LR
    User((Usuario))
    
    subgraph "Gestión de Catálogo"
        UC1[Registrar Producto]
        UC2[Editar Info]
        UC3[Eliminar Producto]
    end
    
    subgraph "Organización Lógica"
        UC4[Crear Categoría]
        UC5[Asignar a Espacio]
        UC6[Filtrar por Categoría]
    end
    
    subgraph "Operaciones"
        UC7[Ajuste de Stock +/-]
        UC8[Búsqueda por SKU/Barcode]
    end

    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6
    User --> UC7
    User --> UC8
```

3. Diagrama de Clases (Clean Architecture)
Implementación del Patrón Repositorio para desacoplar la lógica de negocio de la implementación física de la base de datos.

```mermaid
classDiagram
    class Product {
        +UUID id
        +String sku
        +String name
        +Int quantity
        +updateStock(Int)
    }

    class ProductRepository {
        <<interface>>
        +fetchAll() List
        +save(Product)
        +delete(UUID)
    }

    class SQLiteRepository {
        -Connection db
        +fetchAll() List
    }

    class InventoryInteractor {
        -ProductRepository repo
        +addItem(Product)
        +incrementStock(UUID)
    }

    class InventoryViewModel {
        -InventoryInteractor interactor
        +List products
        +load()
    }

    SQLiteRepository ..|> ProductRepository : "Implementa"
    InventoryInteractor --> ProductRepository : "Usa"
    InventoryViewModel --> InventoryInteractor : "Invoca"
    InventoryInteractor --> Product : "Manipula"
```

📂 Estructura del Proyecto
/Domain: Entidades puras y protocolos de repositorio.

/Application: Casos de uso (Interactors).

/Infrastructure: Implementación de SQLite y servicios de sistema.

/Presentation: Vistas SwiftUI y ViewModels.
