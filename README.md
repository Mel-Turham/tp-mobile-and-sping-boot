# TechConnect — README

Ce dépôt contient le frontend (Flutter) et le backend (Spring Boot) de l'application TechConnect — une plateforme de mise en relation entre utilisateurs et techniciens.

Structure principale :

- `tp-mobile-web/techconnect` — frontend Flutter (mobile + web)
- `tp-mobile-web/techconnect_b` — backend Spring Boot
- `tp-mobile-web/database.sql` — dump PostgreSQL avec schéma et données d'exemple

Important : les instructions ci-dessous supposent que vous travaillez depuis la racine du projet (`tp-mobile-web`). Adaptez les chemins si nécessaire.

---

## Prérequis

- Java 17 (pour le backend)
- Maven (ou utilisation du wrapper `mvnw`)
- PostgreSQL (base de données)
- Flutter (version stable compatible avec le projet)
- `flutter` dans le PATH pour lancer le frontend web
- Outils CLI : `psql` ou un client PostgreSQL pour restaurer `database.sql`

---

## Backend — Spring Boot

Emplacement : `tp-mobile-web/techconnect_b`

1. Configuration essentielle

- Le backend lit sa configuration principale dans `tp-mobile-web/techconnect_b/src/main/resources/application.yml`.
  - Port serveur par défaut : `8080`
  - Source de données : PostgreSQL (URL par défaut `jdbc:postgresql://localhost:5432/techconnect`)
  - Variables d'environnement utilisables :
    - `DB_USERNAME` (par défaut `postgres` si non défini)
    - `DB_PASSWORD` (défini dans `application.yml` par défaut — remplacez-le en production)
    - `JWT_SECRET` (pour signer les JWT ; recommandé de l'overrider en prod)
    - `CORS_ORIGINS` (liste d'origines autorisées)
- Swagger / OpenAPI est activé via `springdoc` — UI disponible une fois le backend lancé.

2. Initialiser la base de données (optionnel)

- Le fichier `tp-mobile-web/database.sql` contient schéma et données d'exemple.
- Exemple de restauration avec `psql` :

```tp-mobile-web/README.md#L221-230
-- depuis la racine du projet
psql -U <username> -d <dbname> -f tp-mobile-web/database.sql
```

- Créez la base `techconnect` si elle n'existe pas :

```tp-mobile-web/README.md#L231-236
createdb -U <username> techconnect
psql -U <username> -d techconnect -f tp-mobile-web/database.sql
```

3. Lancer le backend

- Depuis `tp-mobile-web/techconnect_b` (ou depuis la racine en précisant le chemin) :
- Si vous avez Maven installé :

```tp-mobile-web/README.md#L237-241
cd tp-mobile-web/techconnect_b
mvn spring-boot:run
```

- Si vous préférez utiliser le wrapper Maven inclus :

```tp-mobile-web/README.md#L242-246
# Unix / macOS
./mvnw spring-boot:run

# Windows (PowerShell / cmd)
mvnw.cmd spring-boot:run
```

4. Points d'accès utiles

- API principale : `http://localhost:8080/api/*`
- Swagger UI (OpenAPI) : généralement `http://localhost:8080/swagger-ui.html` ou `http://localhost:8080/swagger-ui/index.html` selon la configuration du starter `springdoc`.
- Logs SQL et comportement JPA contrôlés par `application.yml`.

5. Variables d'environnement recommandées (exemples)

- Linux/macOS :

```tp-mobile-web/README.md#L247-253
export DB_USERNAME=postgres
export DB_PASSWORD=your_db_password
export JWT_SECRET=uneCleSecreteTrèsLongue
```

- Windows (PowerShell) :

```tp-mobile-web/README.md#L254-258
$env:DB_USERNAME="postgres"
$env:DB_PASSWORD="your_db_password"
$env:JWT_SECRET="uneCleSecreteTrèsLongue"
```

---

## Frontend — Flutter (mobile + web)

Emplacement : `tp-mobile-web/techconnect`

1. Configuration

- Le fichier principal de configuration Dart pour les appels HTTP se trouve dans `tp-mobile-web/techconnect/lib/services/api_service.dart`.
- Par défaut, le `baseUrl` est :

```text
http://localhost:8080/api
```

Assurez-vous que le backend tourne sur `localhost:8080` ou modifiez `baseUrl` en conséquence.

2. Lancer l'application en mode web

- Pour lancer le frontend en serveur web (développement) sur le port 5000, utilisez la commande fournie :

```tp-mobile-web/README.md#L259-263
cd tp-mobile-web/techconnect
flutter run -d web-server --web-port=5000
```

- L'application sera servie sur `http://localhost:5000`. Le frontend fera des requêtes vers `http://localhost:8080/api` (ou le `baseUrl` configuré).

3. Autres commandes utiles

- Pour récupérer les dépendances :

```tp-mobile-web/README.md#L264-268
cd tp-mobile-web/techconnect
flutter pub get
```

- Pour exécuter sur mobile (émulateur / appareil) utilisez `flutter run` sans `-d web-server` ou ciblez un device spécifique.

---

## Fonctionnalités (overview)

Backend (exposé via l'API REST)

- Authentification / Autorisation
  - Inscription / Connexion d'utilisateurs
  - JWT pour sécuriser les endpoints
- Gestion des utilisateurs
  - Récupération des informations de l'utilisateur connecté (`/users/me`)
- Gestion des techniciens
  - Liste paginée de techniciens
  - Recherche (par domaine, ville, etc.)
  - Détails d'un technicien
- Contact
  - Envoi de `ContactRequest` (demande de mise en relation) vers un technicien
  - Stockage des requêtes de contact
- Notes / Avis (Ratings)
  - Créer une note pour un technicien
  - Modifier / Supprimer sa note
  - Récupérer notes paginées par technicien ou par utilisateur
  - Statistiques de notation pour un technicien (moyenne, nombre)
  - Protection contre double notation (contrainte unique user+technician)
- Email
  - Envoi d'emails via configuration SMTP (configurable dans `application.yml`)
- Documentation API via OpenAPI/Swagger

Frontend (Flutter)

- Interface utilisateur pour :
  - Parcourir la liste des techniciens (pagination)
  - Filtrer / rechercher techniciens
  - Consulter la fiche d'un technicien
  - S'authentifier (login / register)
  - Envoyer une demande de contact à un technicien
  - Laisser une note / commentaire et gérer ses notes
- Communication avec le backend via `Dio` (implémentée dans `lib/services/api_service.dart`)
  - Gère injection du token JWT dans les headers
  - Endpoints principaux utilisés : `/auth/*`, `/technicians`, `/contact/*`, `/ratings/*`, `/users/*`

---

## Bonnes pratiques et sécurité

- Ne laissez pas de secrets (mot de passe DB, clefs SMTP, `JWT_SECRET`) en clair dans le dépôt. Utilisez des variables d'environnement ou un gestionnaire de secrets.
- En production, configurez CORS pour autoriser uniquement les origines de confiance.
- Changez la configuration SMTP de développement pour un service adapté en production.
- Vérifiez que la base de données de production ne laisse pas les mêmes identifiants que le développement.

---

## Dépannage rapide

- Erreur de connexion PostgreSQL :
  - Vérifiez que la base `techconnect` existe, que l'utilisateur/mot de passe sont corrects et que PostgreSQL écoute sur `localhost:5432`.
- Erreur 401 / JWT :
  - Vérifiez que vous envoyez le header `Authorization: Bearer <token>`.
- Frontend qui ne communique pas avec le backend :
  - Vérifiez le `baseUrl` dans `tp-mobile-web/techconnect/lib/services/api_service.dart`.
  - Vérifiez les règles CORS du backend (`application.yml` et configuration `SecurityConfig`).

---

## Fichiers importants

- Backend :
  - `tp-mobile-web/techconnect_b/pom.xml` — dépendances Maven
  - `tp-mobile-web/techconnect_b/src/main/resources/application.yml` — configuration (BD, mail, jwt, cors)
  - `tp-mobile-web/techconnect_b/src/main/java/com/example/techconnect/backend/controller` — controllers REST
- Frontend :
  - `tp-mobile-web/techconnect/lib/services/api_service.dart` — configuration des appels API (baseUrl, endpoints)
  - `tp-mobile-web/techconnect/pubspec.yaml` — dépendances Flutter
