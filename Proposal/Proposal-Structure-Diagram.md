# Diagram Struktur Proposal

## Struktur Proposal Penawaran

```mermaid
graph TD
    A[Proposal Penawaran<br/>Sistem Kolam Renang Syariah] --> B[BAB I - PENDAHULUAN]
    A --> C[BAB II - SOLUSI YANG DITAWARKAN]
    A --> D[BAB III - RINCIAN BIAYA DAN TEKNOLOGI]
    A --> E[BAB IV - METODOLOGI DAN TIMELINE]
    A --> F[BAB V - DUKUNGAN DAN KEUNGGULAN]
    A --> G[LAMPIRAN]

    B --> B1[1.1 Profil Banjart Media]
    B --> B2[1.2 Pemahaman Kebutuhan]
    B --> B3[1.3 Visi dan Misi Proyek]
    B --> B4[1.4 Manfaat yang Akan Diperoleh]

    C --> C1[2.1 Pendekatan Implementasi Efisien]
    C --> C2[2.2 Modul-Modul yang Diimplementasikan]
    C --> C3[2.3 Arsitektur Sistem]
    C --> C4[2.4 Integrasi dan Konektivitas]
    C --> C5[2.5 Keunggulan Solusi]

    D --> D1[3.1 Rincian Biaya Investasi]
    D --> D2[3.2 Biaya Service]
    D --> D3[3.3 Teknologi yang Digunakan]
    D --> D4[3.4 Infrastructure & Deployment]
    D --> D5[3.5 Value Proposition]

    E --> E1[4.1 Metodologi Pengembangan]
    E --> E2[4.2 Timeline Pengembangan]
    E --> E3[4.3 Ketentuan Pembayaran]
    E --> E4[4.4 Quality Assurance & Testing]
    E --> E5[4.5 Risk Management]
    E --> E6[4.6 Communication & Reporting]

    F --> F1[5.1 Dukungan dan Pemeliharaan]
    F --> F2[5.2 Keunggulan Sistem Banjart Media]
    F --> F3[5.3 Syarat dan Ketentuan]
    F --> F4[5.4 Langkah Selanjutnya]
    F --> F5[5.5 Penutup]

    G --> G1[A. Dokumen Pendukung]
    G --> G2[B. Referensi Teknis]
    G --> G3[C. Diagram Arsitektur]
    G --> G4[D. Testing Strategy]
    G --> G5[E. Security Considerations]
    G --> G6[F. Performance Benchmarks]
    G --> G7[G. Deployment Guide]
```

## Timeline Implementasi

```mermaid
gantt
    title Timeline Pengembangan Sistem Kolam Renang Syariah
    dateFormat  YYYY-MM-DD
    section Discovery & Design
    Discovery Phase           :done, discovery, 2025-09-01, 1w
    Design Phase             :done, design, after discovery, 2w

    section Development Sprints
    Sprint 1 - Foundation    :active, sprint1, after design, 1w
    Sprint 2 - User Mgmt     :sprint2, after sprint1, 1w
    Sprint 3 - Booking Core  :sprint3, after sprint2, 1w
    Sprint 4 - Payment       :sprint4, after sprint3, 1w
    Sprint 5 - Admin Panel   :sprint5, after sprint4, 1w
    Sprint 6 - Real-time     :sprint6, after sprint5, 1w
    Sprint 7 - Cafe Mgmt     :sprint7, after sprint6, 1w
    Sprint 8 - Optimization  :sprint8, after sprint7, 1w

    section Deployment & Support
    Deployment Phase         :deploy, after sprint8, 1w
    Post-Launch Support      :support, after deploy, 2w
```

## Arsitektur Sistem

```mermaid
graph TB
    subgraph "Client Layer"
        A[Web Browser]
        B[Mobile Browser]
        C[Admin Dashboard]
    end

    subgraph "Application Layer"
        D[React Frontend]
        E[Laravel Backend]
        F[API Gateway]
    end

    subgraph "Business Logic Layer"
        G[Authentication Service]
        H[Booking Service]
        I[Payment Service]
        J[Member Service]
        K[Session Service]
    end

    subgraph "Data Layer"
        L[MySQL Database]
        M[Redis Cache]
        N[File Storage]
    end

    subgraph "External Services"
        O[Google SSO]
        P[SMS Gateway]
        Q[Email Service]
    end

    A --> D
    B --> D
    C --> D
    D --> F
    F --> E
    E --> G
    E --> H
    E --> I
    E --> J
    E --> K
    G --> L
    H --> L
    I --> L
    J --> L
    K --> L
    E --> M
    E --> N
    G --> O
    E --> P
    E --> Q
```

## Breakdown Biaya

```mermaid
pie title Breakdown Biaya Investasi
    "Core Development" : 75
    "Testing & QA" : 9
    "Deployment & Setup" : 6
    "Biaya Tambahan" : 10
```

## Modul Sistem

```mermaid
graph LR
    subgraph "Frontend Modules"
        A[Portal Member & Guest]
        B[Admin Dashboard]
        C[Mobile Optimization]
    end

    subgraph "Backend Modules"
        D[Core System]
        E[Authentication System]
        F[Payment System]
        G[Real-time Features]
    end

    subgraph "Database & Infrastructure"
        H[Database Design]
        I[API Development]
        J[Security Implementation]
    end

    subgraph "Testing & Quality"
        K[Unit Testing]
        L[Integration Testing]
        M[Performance Testing]
    end

    A --> D
    B --> E
    C --> F
    D --> H
    E --> I
    F --> J
    G --> K
    H --> L
    I --> M
```

## Metodologi Pengembangan

```mermaid
flowchart TD
    A[Discovery Phase] --> B[Design Phase]
    B --> C[Development Sprints]
    C --> D[Deployment Phase]
    D --> E[Post-Launch Support]

    subgraph "Development Sprints"
        C1[Sprint 1: Foundation]
        C2[Sprint 2: User Management]
        C3[Sprint 3: Booking System]
        C4[Sprint 4: Payment System]
        C5[Sprint 5: Admin Dashboard]
        C6[Sprint 6: Real-time Features]
        C7[Sprint 7: Cafe Management]
        C8[Sprint 8: Optimization]
    end

    C --> C1
    C1 --> C2
    C2 --> C3
    C3 --> C4
    C4 --> C5
    C5 --> C6
    C6 --> C7
    C7 --> C8
    C8 --> D
```

---

**Dokumen**: Diagram Struktur Proposal  
**Versi**: 1.0  
**Tanggal**: 26 Agustus 2025  
**Proyek**: Sistem Manajemen Kolam Renang Syariah Raujan Pool
