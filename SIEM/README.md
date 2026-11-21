# AzureLab SIEM – Wazuh Stack (SIEM as Code)

Konteneryzowane środowisko **Wazuh 4.9.2** (Single-Node) z własnymi regułami detekcji MITRE ATT&CK oraz integracjami Threat Intelligence (VirusTotal, AbuseIPDB).

## Struktura katalogów

```text
.
├── config/
│   ├── integrations/
│   │   └── custom-abuseipdb.py      # Integracja z API AbuseIPDB
│   ├── wazuh_indexer_ssl_certs/     # Katalog na wygenerowane lokalnie certyfikaty SSL (ignorowany przez Git)
│   ├── agent_windows_shared.conf    # Konfiguracja grupowa dla agentów Windows
│   ├── certs.yml                    # Generator certyfikatów SSL dla klastra
│   ├── local_rules.xml              # Własne reguły detekcji (MITRE ATT&CK)
│   ├── opensearch_dashboards.yml    # Konfiguracja Wazuh Dashboard
│   ├── wazuh.indexer.yml            # Konfiguracja Wazuh Indexer
│   └── wazuh_manager.conf           # Główny plik konfiguracyjny Wazuh Manager (ossec.conf)
├── scripts/
│   ├── install-agent-linux.sh       # Skrypt instalacyjny agenta dla Linux
│   └── install-agent-windows.ps1    # Skrypt instalacyjny agenta dla Windows
├── .env.example                     # Szablon zmiennych środowiskowych
├── .gitignore                       # Wykluczenia sekretów i certyfikatów
└── docker-compose.yml               # Główny stos Wazuh (Manager, Indexer, Dashboard)
```

---

## Wymagania wstępne

* **Docker Desktop** (z włączonym silnikiem WSL2 na Windows) lub **Docker Engine + Docker Compose v2** na Linux.
* Minimum **4 GB wolnej pamięci RAM** (Indexer ma nałożony limit `-Xms1g -Xmx1g`).
* **Wymaganie jądra Linux / WSL2 (`vm.max_map_count`):**
  OpenSearch wymaga zwiększonego limitu mapowania pamięci wirtualnej, w przeciwnym razie kontener `wazuh.indexer` będzie się restartował.

  * **Windows (PowerShell jako Administrator – wymagane po każdym restarcie Dockera/PC):**
    ```powershell
    wsl -d docker-desktop sysctl -w vm.max_map_count=262144
    ```
  * **Linux:**
    ```bash
    sudo sysctl -w vm.max_map_count=262144
    ```

---

## Instrukcja uruchomienia krok po kroku

### 1. Konfiguracja zmiennych środowiskowych
Skopiuj plik szablonu `.env.example` do `.env` i uzupełnij własne klucze API (VirusTotal, AbuseIPDB):

```bash
cp .env.example .env
```

> **Uwaga dotycząca haseł:** Domyślnie obraz `wazuh-indexer:4.9.2` inicjuje bazę hasłami `admin` (użytkownik `admin`) oraz `kibanaserver` (użytkownik `kibanaserver`). Jeśli w pliku `.env` ustawisz własne hasła dla `INDEXER_PASSWORD` i `DASHBOARD_PASSWORD`, po pierwszym uruchomieniu stosu wykonaj komendę synchronizacji haseł z sekcji **Rozwiązywanie problemów** poniżej.

### 2. Wygenerowanie certyfikatów SSL
Certyfikaty nie są przechowywane w repozytorium. Przed pierwszym uruchomieniem wygeneruj je lokalnie:

```bash
docker run --rm -u 0 --entrypoint bash -v ./config/certs.yml:/config/certs.yml -v ./config/wazuh_indexer_ssl_certs:/out wazuh/wazuh-certs-generator:0.0.2 -c "mkdir -p /certificates && /entrypoint.sh && chmod 644 /certificates/* && cp -f /certificates/* /out/"
```

### 3. Uruchomienie kontenerów
```bash
docker compose up -d
```

Odczekaj ok. **60 sekund** na pełną inicjalizację indeksów OpenSearch i API Menedżera. Stan usług sprawdzisz poleceniem:
```bash
docker compose ps
```

### 4. Dostęp do interfejsów
* **Wazuh Dashboard:** `https://localhost` *(wymagane `https://`, zaakceptuj ostrzeżenie o samopodpisanym certyfikacie)*
  * Login: `admin`
  * Hasło: `admin` (wartość `INDEXER_PASSWORD` z pliku `.env`)
* **Wazuh Indexer (stan klastra):** `https://localhost:9200/_cluster/health?pretty`
* **Wazuh Manager API:** `https://localhost:55000`

---

## Rozwiązywanie problemów (Troubleshooting)

### Dashboard pokazuje `Wazuh dashboard server is not ready yet` (błąd autoryzacji w logach)
Jeśli ustawiłeś niestandardowe hasła w `.env`, zaktualizuj hashe w działającym kontenerze `wazuh.indexer`:

**PowerShell (Windows):**
```powershell
@'
export JAVA_HOME=/usr/share/wazuh-indexer/jdk
SEC_DIR="/usr/share/wazuh-indexer/opensearch-security"
export H_ADM=$(/usr/share/wazuh-indexer/plugins/opensearch-security/tools/hash.sh -p "TWOJE_INDEXER_PASSWORD" | tail -n 1)
export H_DSH=$(/usr/share/wazuh-indexer/plugins/opensearch-security/tools/hash.sh -p "TWOJE_DASHBOARD_PASSWORD" | tail -n 1)

python3 - <<'EOF'
import os, re
p = "/usr/share/wazuh-indexer/opensearch-security/internal_users.yml"
t = open(p).read()
t = re.sub(r'(admin:\s+hash:\s+)[^\n]+', lambda m: m.group(1) + '"' + os.environ["H_ADM"].strip() + '"', t)
t = re.sub(r'(kibanaserver:\s+hash:\s+)[^\n]+', lambda m: m.group(1) + '"' + os.environ["H_DSH"].strip() + '"', t)
open(p, "w").write(t)
EOF

/usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh \
  -f "$SEC_DIR/internal_users.yml" -t internalusers -icl -nhnv \
  -cacert /usr/share/wazuh-indexer/certs/root-ca.pem \
  -cert /usr/share/wazuh-indexer/certs/admin.pem \
  -key /usr/share/wazuh-indexer/certs/admin-key.pem -h localhost
'@ | docker exec -u 0 -i siem-wazuh.indexer-1 bash -c "tr -d '\r' | bash"

docker compose restart wazuh.dashboard wazuh.manager
```