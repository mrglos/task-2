# Task 2 - Infrastructure as Code

Repozytorium zawiera kompletną definicję infrastruktury chmurowej w **GCP** zrealizowaną przy użyciu **Terraform**. Projekt został zaprojektowany zgodnie z paradygmatem High Availability (HA) oraz zasadami Zero Trust Security.

## 🏗 Architektura Systemu

Zaprojektowana infrastruktura składa się z następujących komponentów:

- **VPC & Networking:** Całkowicie izolowana sieć z prywatnymi podsieciami. Brak publicznych adresów IP dla instancji obliczeniowych.
- **High Availability Compute:** Regionalna grupa instancji (Managed Instance Group) rozproszona w 3 strefach dostępności z automatycznym skalowaniem (Autoscaler).
- **Load Balancing:** Globalny HTTP Load Balancer stanowiący jedyny punkt wejścia do aplikacji.
- **Database (Cloud SQL):** W pełni zarządzana instancja PostgreSQL w trybie HA (Regional) z dostępem wyłącznie przez prywatne IP (VPC Peering).
- **Storage (GCS):** Zabezpieczony kubełek z wymuszonym Uniform Bucket-Level Access.

## 🛡️ Security Best Practices

W projekcie zaimplementowano zaawansowane mechanizmy bezpieczeństwa:

1.  **Identity-Aware Proxy (IAP):** Dostęp SSH do maszyn odbywa się bez publicznych adresów IP i bastion hostów, poprzez bezpieczny tunel IAP.
2.  **Cloud NAT:** Maszyny w prywatnych podsieciach mogą bezpiecznie pobierać aktualizacje bez bycia wystawionymi na bezpośredni ruch z internetu.
3.  **Principle of Least Privilege:** Każda warstwa (Compute, DB) posiada dedykowane Service Account z minimalnymi wymaganymi uprawnieniami.
4.  **Zero Trust Networking:** Reguły firewall ograniczają ruch wyłącznie do niezbędnych zakresów (np. Google Health Checks).

## 🚀 Uruchomienie

1.  Zainicjalizuj Terraform:
    ```bash
    cd environments/prod
    terraform init
    ```
2.  Sprawdź plan zmian:
    ```bash
    terraform plan -var="project_id=YOUR_PROJECT_ID" -var="db_password=YOUR_SAFE_PASSWORD"
    ```
3.  Zaaplikuj infrastrukturę:
    ```bash
    terraform apply -var="project_id=YOUR_PROJECT_ID" -var="db_password=YOUR_SAFE_PASSWORD"
    ```

Po zakończeniu, adres IP Load Balancera zostanie wyświetlony w sekcji `outputs`.
