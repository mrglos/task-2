# Task 2 - Infrastructure as Code

Repozytorium zawiera kompletną definicję infrastruktury chmurowej w **GCP** zrealizowaną przy użyciu **Terraform**. Projekt został zaprojektowany zgodnie z paradygmatem High Availability (HA) oraz zasadami Zero Trust Security.

## 🏗 Architektura Systemu

Zaprojektowana infrastruktura składa się z następujących komponentów:

- **VPC & Networking:** Całkowicie izolowana sieć z prywatnymi podsieciami. Brak publicznych adresów IP dla instancji obliczeniowych.
- **High Availability Compute:** Regionalna grupa instancji (Managed Instance Group) rozproszona w 3 strefach dostępności z automatycznym skalowaniem (Autoscaler).
- **Load Balancing:** Globalny HTTP Load Balancer stanowiący jedyny punkt wejścia do aplikacji.
- **Database (Cloud SQL):** W pełni zarządzana instancja PostgreSQL w trybie HA (Regional) z dostępem wyłącznie przez prywatne IP (VPC Peering).
- **Storage (GCS):** Zabezpieczony kubełek z wymuszonym Uniform Bucket-Level Access (służący również jako backend dla stanu Terraform).

## 🛡️ Security Best Practices

W projekcie zaimplementowano zaawansowane mechanizmy bezpieczeństwa:

1.  **Identity-Aware Proxy (IAP):** Dostęp SSH do maszyn odbywa się bez publicznych adresów IP i bastion hostów, poprzez bezpieczny tunel IAP.
2.  **Cloud NAT:** Maszyny w prywatnych podsieciach mogą bezpiecznie pobierać aktualizacje bez bycia wystawionymi na bezpośredni ruch z internetu.
3.  **Principle of Least Privilege:** Każda warstwa (Compute, DB) posiada dedykowane Service Account z minimalnymi wymaganymi uprawnieniami.
4.  **Zero Trust Networking:** Reguły firewall ograniczają ruch wyłącznie do niezbędnych zakresów (np. Google Health Checks).
5.  **Dynamic Secrets Management:** Hasło do bazy danych nie jest przechowywane w kodzie. Jest generowane dynamicznie podczas wdrożenia i bezpiecznie składowane w **Google Secret Manager**, skąd aplikacje mogą je pobierać poprzez API.

## 🚀 Uruchomienie

### Wymagania wstępne

Upewnij się, że jesteś zalogowany do Google Cloud CLI (ADC), aby Terraform mógł uwierzytelnić się w GCP:

```bash
gcloud auth application-default login
```

### Wdrożenie

1. Ustaw zmienną środowiskową `GCP_PROJECT_ID` na ID Twojego projektu GCP:

   ```bash
   export GCP_PROJECT_ID="twoje-id-projektu"
   ```

2. Stwórz bucket do bezpiecznego przechowywania stanu Terraform:

   ```bash
   gcloud storage buckets create gs://${GCP_PROJECT_ID}-tfstate --location=europe-central2 --uniform-bucket-level-access
   gcloud storage buckets update gs://${GCP_PROJECT_ID}-tfstate --versioning
   ```

3. Włącz wymagane usługi API w projekcie GCP (jeśli używasz czystego projektu):

   ```bash
   gcloud services enable compute.googleapis.com servicenetworking.googleapis.com sqladmin.googleapis.com secretmanager.googleapis.com --project=${GCP_PROJECT_ID}
   ```

4. Zainicjalizuj Terraform (używając utworzonego przed chwilą bucketu jako backendu):

   ```bash
   cd environments/prod
   terraform init -backend-config="bucket=${GCP_PROJECT_ID}-tfstate"
   ```

5. Sprawdź plan zmian:

   ```bash
   terraform plan -var="project_id=${GCP_PROJECT_ID}"
   ```

6. Zaaplikuj infrastrukturę:
   ```bash
   terraform apply -var="project_id=${GCP_PROJECT_ID}"
   ```

Po zakończeniu, publiczny adres IP Load Balancera (punkt wejścia do aplikacji Nginx) zostanie wyświetlony w sekcji `outputs`. _Uwaga: Pełna propagacja reguł globalnego Load Balancera Google może zająć od 3 do 10 minut._

## 🧹 Czyszczenie środowiska (Teardown)

Aby uniknąć niepotrzebnych kosztów, po zakończeniu testów zniszcz infrastrukturę:

```bash
terraform destroy -var="project_id=${GCP_PROJECT_ID}"
```
