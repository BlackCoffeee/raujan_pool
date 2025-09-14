# File Storage Architecture Diagrams

## 📁 Laravel Storage Architecture

### **Before: AWS S3 Architecture**

```mermaid
graph TD
    A[Frontend Upload] --> B[Laravel API]
    B --> C[File Validation]
    C --> D[AWS S3 Upload]
    D --> E[S3 Bucket]
    E --> F[CloudFront CDN]
    F --> G[File Access]
    
    subgraph "AWS Services"
        E
        F
        H[S3 API]
        I[CloudFront Distribution]
    end
    
    D --> H
    F --> I
```

### **After: Laravel Storage Architecture**

```mermaid
graph TD
    A[Frontend Upload] --> B[Laravel API]
    B --> C[File Validation]
    C --> D[Laravel Storage]
    D --> E[Local File System]
    E --> F[File Access]
    
    subgraph "Laravel Storage"
        D
        G[storage/app/public]
        H[storage/app/documents]
        I[storage/app/uploads]
    end
    
    D --> G
    D --> H
    D --> I
    
    subgraph "File Types"
        J[Profile Images]
        K[Documents]
        L[Payment Proofs]
        M[Cafe Images]
    end
    
    G --> J
    H --> K
    H --> L
    I --> M
```

## 🔄 File Storage Flow

### **Upload Process**

```mermaid
sequenceDiagram
    participant U as User
    participant F as Frontend
    participant A as Laravel API
    participant S as Laravel Storage
    participant D as Database
    
    U->>F: Select File
    F->>A: POST /api/upload
    A->>A: Validate File
    A->>S: Store File
    S->>S: Generate Path
    S-->>A: Return Path
    A->>D: Save File Info
    D-->>A: Success
    A-->>F: File URL
    F-->>U: Upload Complete
```

### **File Access Process**

```mermaid
sequenceDiagram
    participant U as User
    participant F as Frontend
    participant A as Laravel API
    participant S as Laravel Storage
    
    U->>F: Request File
    F->>A: GET /api/file/{id}
    A->>A: Check Permissions
    A->>S: Get File
    S-->>A: File Content
    A-->>F: File Response
    F-->>U: Display File
```

## 🗂️ Directory Structure

### **Laravel Storage Layout**

```mermaid
graph TD
    A[storage/app] --> B[public/]
    A --> C[documents/]
    A --> D[uploads/]
    A --> E[temporary/]
    
    B --> B1[avatars/]
    B --> B2[member-photos/]
    B --> B3[cafe-images/]
    
    C --> C1[member-documents/]
    C --> C2[payment-proofs/]
    C --> C3[contracts/]
    C --> C4[kyc-documents/]
    
    D --> D1[profile-images/]
    D --> D2[menu-images/]
    D --> D3[announcements/]
    
    E --> E1[pending-uploads/]
    E --> E2[temp-files/]
```

## 🔐 Security & Access Control

### **File Security Architecture**

```mermaid
graph TD
    A[File Upload Request] --> B[Authentication Check]
    B --> C[Authorization Check]
    C --> D[File Type Validation]
    D --> E[Size Validation]
    E --> F[Virus Scan]
    F --> G[Secure Storage]
    
    H[File Access Request] --> I[Authentication Check]
    I --> J[Permission Check]
    J --> K[File Path Validation]
    K --> L[Serve File]
    
    subgraph "Security Layers"
        B
        C
        D
        E
        F
        I
        J
        K
    end
```

## 📊 Backup Strategy

### **Backup Architecture**

```mermaid
graph TD
    A[Laravel Storage] --> B[Daily Backup]
    B --> C[Local Backup]
    B --> D[External Backup]
    
    C --> C1[Compressed Archive]
    C --> C2[Incremental Backup]
    
    D --> D1[Cloud Storage]
    D --> D2[Remote Server]
    
    subgraph "Backup Types"
        E[Full Backup - Weekly]
        F[Incremental - Daily]
        G[Differential - Every 6 Hours]
    end
    
    B --> E
    B --> F
    B --> G
```

## 🚀 Performance Optimization

### **File Storage Performance**

```mermaid
graph TD
    A[File Request] --> B{Cache Check}
    B -->|Hit| C[Serve from Cache]
    B -->|Miss| D[Read from Storage]
    D --> E[Store in Cache]
    E --> F[Serve File]
    
    G[File Upload] --> H[Compression]
    H --> I[Validation]
    I --> J[Storage]
    J --> K[Cache Update]
    
    subgraph "Optimization Features"
        L[Image Compression]
        M[File Compression]
        N[CDN Integration]
        O[Lazy Loading]
    end
```

## 📈 Monitoring & Analytics

### **Storage Monitoring**

```mermaid
graph TD
    A[Storage Metrics] --> B[Disk Usage]
    A --> C[File Count]
    A --> D[Upload Frequency]
    A --> E[Access Patterns]
    
    B --> F[Alert System]
    C --> F
    D --> F
    E --> F
    
    F --> G[Admin Dashboard]
    F --> H[Email Notifications]
    F --> I[System Logs]
    
    subgraph "Monitoring Tools"
        J[Laravel Telescope]
        K[Custom Metrics]
        L[File System Monitoring]
    end
    
    G --> J
    G --> K
    G --> L
```

---

**Last Updated**: 26 Agustus 2025  
**Version**: 1.0  
**Status**: ✅ Implemented
