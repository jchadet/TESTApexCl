# Test des Named Credentials SAP

Ce dossier contient des scripts Apex anonymous pour tester les 3 Named Credentials configurés pour les callouts SAP.

## 🚀 Démarrage rapide - Script consolidé

**Pour tester tous les services en une seule exécution**, utilisez le script consolidé :

```bash
sf apex run -f scripts/apex/testAllSAPServices.apex -o origame5-dev
```

Ce script teste automatiquement les 3 Named Credentials et affiche :
- ✓ Un tableau récapitulatif avec le statut de chaque service
- 📊 Des statistiques de réussite/échec
- 🎯 Un verdict global et des recommandations ciblées

**Paramètres à adapter dans `testAllSAPServices.apex` :**
- Ligne 149 : `pointId` pour Service GreenAlp (ex: '125278EC1')
- Ligne 150 : `loginUtilisateur` pour Service GreenAlp (ex: 'user@example.com')
- Ligne 215 : `CITY_CODE` (code INSEE, ex: '69387' pour Lyon 7ème)
- Ligne 216 : `ENERGY` ('01'=Electricité, '02'=Gaz)
- Ligne 217 : `UIL_USAGE` ('DOM'=Domestique, 'PRO'=Professionnel)
- Ligne 218 : `CAR` (puissance avec espace insécable, ex: '4\u202f500')

---

## 📋 Vue d'ensemble des services SAP

| Named Credential | Nom Fonctionnel | Script de Test | Méthode |
|-----------------|-----------------|----------------|---------|
| **SAP_Endpoint_Service** | Service GreenAlp | `testSAPEndpointService.apex` | POST |
| **SAP BTP http** | Service Activation | `testSAPBTPActivation.apex` | GET |
| **SAP_Product_Catalog_Service** | Service des Produits | `testSAPProductCatalog.apex` | POST |

---

## 1️⃣ SAP Endpoint Service (Service GreenAlp)

### Description
Service pour interroger les détails d'un point de livraison (PDL) dans SAP.

### Configuration
- **Named Credential** : `SAP_Endpoint_Service`
- **External Credential** : `SAP Endpoint ExternalService`
- **Endpoint** : `https://geg-api.test.apimanagement.eu10.hana.ondemand.com:443/DG`
- **Script de test** : `testSAPEndpointService.apex`

### Prérequis
- La classe Apex `SAPDetailPointServiceCallout` doit exister dans votre org

### Paramètres à adapter
Ouvrez `testSAPEndpointService.apex` et modifiez :
```apex
String pointId = '125278EC1';  // Point ID à tester
String loginUtilisateur = 'votre.email@example.com';  // Votre login
```

### Exécution
```bash
# Via Developer Console : copier/coller le contenu et exécuter
# Ou via SF CLI :
sf apex run -f scripts/apex/testSAPEndpointService.apex -o origame5-dev
```

### Résultat attendu
- ✓ **SUCCÈS** : Retourne les données du point (informations générales, index, etc.)
- ✗ **ÉCHEC** : Vérifier que le point ID existe dans SAP

---

## 2️⃣ SAP BTP HTTP (Service Activation)

### Description
Service pour l'activation de contrats et l'envoi de documents contractuels vers SAP.

### Configuration
- **Named Credential** : `SAP BTP http`
- **External Credential** : `SAP BTP HTTP External Credential`
- **Endpoint** : `https://geg-distributeur-dev.it-cpi024-rt.cfapps.eu10-002.hana.ondemand.com/http/DF/SalesForce/activation`
- **Script de test** : `testSAPBTPActivation.apex`

### Prérequis
- Le Custom Metadata Type `SAP_IntegrationSettings__mdt` doit exister avec :
  - `Endpoint__c` : L'URL du service
  - `Username__c` : Nom d'utilisateur SAP
  - `Password__c` : Mot de passe SAP

### Configuration du Custom Metadata
1. Allez dans **Setup** > **Custom Metadata Types**
2. Cliquez sur **SAP_IntegrationSettings**
3. Cliquez sur **Manage Records**
4. Créez ou modifiez un enregistrement avec les valeurs ci-dessus

### Exécution
```bash
# Via Developer Console : copier/coller le contenu et exécuter
# Ou via SF CLI :
sf apex run -f scripts/apex/testSAPBTPActivation.apex -o origame5-dev
```

### Résultat attendu
- ✓ **SUCCÈS** : Récupération du CSRF token → Authentification OK
- ✗ **ÉCHEC** : Vérifier les credentials dans le Custom Metadata

### Note importante
Ce test effectue **uniquement un GET** pour récupérer le CSRF token. Il ne fait pas de POST (envoi de données). C'est suffisant pour vérifier que la connexion et l'authentification fonctionnent.

---

## 3️⃣ SAP Product Catalog Service (Service des Produits)

### Description
Service pour rechercher des produits énergétiques et obtenir des simulations de prix.

### Configuration
- **Named Credential** : `SAP_Product_Catalog_Service`
- **External Credential** : `ProductCatalogExternalService`
- **Endpoint** : `https://geg-api.test.apimanagement.eu10.hana.ondemand.com:443/DF/ProductCatalog`
- **Script de test** : `testSAPProductCatalog.apex`

### Paramètres à adapter
Ouvrez `testSAPProductCatalog.apex` et modifiez les paramètres de recherche :
```apex
'CITY_CODE' => '69387',        // Code INSEE de la commune (ex: 69387 = Lyon 7ème)
'ENERGY' => '01',              // Code énergie : 01=Electricité, 02=Gaz
'UIL_USAGE' => 'DOM',          // Usage : DOM=Domestique, PRO=Professionnel
'CAR' => '4\u202f500',         // Puissance avec espace insécable
'GREEN_OPTION' => 'FOR',       // Option verte : FOR, ECO, etc.
'GREEN_RATE' => '100',         // Taux d'énergie verte en % (0-100)
'SERVICE_OPT' => '0xf926425',  // Code hexadécimal des options
'REFDATE' => DateTime.now().format('yyyyMMdd') // Date au format YYYYMMDD
```

**Note importante :** Ces valeurs sont basées sur un appel SAP réel qui fonctionne. Adaptez-les selon vos besoins de test.

### Exécution
```bash
# Via Developer Console : copier/coller le contenu et exécuter
# Ou via SF CLI :
sf apex run -f scripts/apex/testSAPProductCatalog.apex -o origame5-dev
```

### Résultat attendu
- ✓ **SUCCÈS** : Retourne une liste de produits avec simulations de prix (HT, TTC, mensualités)
- ✗ **ÉCHEC 400** : Vérifier les paramètres de la requête (valeurs invalides)

---

## 🛠️ Scripts utilitaires

### listNamedCredentials.apex
Script pour lister tous les Named Credentials de votre org et identifier ceux liés à SAP.

**Exécution :**
```bash
sf apex run -f scripts/apex/listNamedCredentials.apex -o origame5-dev
```

**Usage :** À exécuter en premier pour vérifier les noms exacts des Named Credentials.

---

## 📊 Interprétation des résultats

Tous les scripts affichent des symboles clairs pour indiquer le statut :

- **✓ SUCCÈS** : Named Credential configuré correctement (HTTP 200-299)
- **✗ ÉCHEC** : Problème de configuration ou d'authentification
- **⚠ AVERTISSEMENT** : Le callout fonctionne mais retourne un code inattendu

### Codes de statut HTTP courants

| Code | Signification | Action à prendre |
|------|---------------|------------------|
| 200-299 | Succès | Named Credential OK ✓ |
| 400 | Bad Request | Vérifier les paramètres de la requête |
| 401 | Non autorisé | Vérifier l'External Credential (username/password/token) |
| 403 | Interdit | Vérifier les permissions SAP |
| 404 | Non trouvé | Vérifier l'URL de l'endpoint ou l'ID recherché |
| 500-599 | Erreur serveur SAP | Contacter l'équipe SAP |

---

## 🔧 Troubleshooting

### Problème : "Unauthorized endpoint"
**Cause :** L'URL n'est pas autorisée dans Remote Site Settings

**Solution :**
1. Allez dans **Setup** > **Remote Site Settings**
2. Cliquez sur **New Remote Site**
3. Ajoutez les URLs suivantes :
   - `https://geg-api.test.apimanagement.eu10.hana.ondemand.com`
   - `https://geg-distributeur-dev.it-cpi024-rt.cfapps.eu10-002.hana.ondemand.com`

### Problème : "Invalid named credential"
**Cause :** Le nom du Named Credential est incorrect ou n'existe pas

**Solution :**
1. Exécutez `listNamedCredentials.apex` pour voir les noms exacts
2. Vérifiez dans **Setup** > **Named Credentials**

### Problème : HTTP 401/403
**Cause :** Credentials invalides ou expirés

**Solution :**
1. Vérifiez l'External Credential associé
2. Testez les credentials directement dans SAP
3. Vérifiez que l'utilisateur SAP a les permissions nécessaires

### Problème : "Read timed out"
**Cause :** Le serveur SAP ne répond pas

**Solution :**
1. Vérifier la connectivité réseau vers SAP
2. Vérifier que le service SAP est opérationnel
3. Contacter l'équipe SAP si le problème persiste

### Problème : SAP_IntegrationSettings__mdt introuvable
**Cause :** Le Custom Metadata Type n'existe pas (pour SAP BTP HTTP)

**Solution :**
1. Allez dans **Setup** > **Custom Metadata Types**
2. Créez le type `SAP_IntegrationSettings__mdt` avec les champs :
   - `Endpoint__c` (Text)
   - `Username__c` (Text)
   - `Password__c` (Text, Protected)
3. Créez un enregistrement avec les valeurs de connexion SAP

---

## 📝 Bonnes pratiques

1. **Testez dans l'ordre :**
   - Commencez par `testSAPBTPActivation.apex` (GET simple)
   - Puis `testSAPEndpointService.apex`
   - Enfin `testSAPProductCatalog.apex`

2. **Activez les logs détaillés :**
   - Dans Developer Console : **Debug** > **Change Log Levels**
   - Mettez **Apex Code** à **FINEST**

3. **Utilisez des données de test valides :**
   - Point ID existant dans SAP
   - Code postal/ville valide
   - Paramètres cohérents avec votre contexte

4. **En cas d'échec :**
   - Lisez attentivement les messages d'erreur
   - Consultez la section "SOLUTIONS POSSIBLES" dans les logs
   - Vérifiez les configurations Salesforce ET SAP

---

## 📚 Ressources

- [Named Credentials - Salesforce Documentation](https://help.salesforce.com/articleView?id=sf.named_credentials_about.htm)
- [External Credentials - Salesforce Documentation](https://help.salesforce.com/articleView?id=sf.external_credentials_about.htm)
- [Remote Site Settings - Salesforce Documentation](https://help.salesforce.com/articleView?id=sf.configuring_remoteproxy.htm)
- [Custom Metadata Types - Salesforce Documentation](https://help.salesforce.com/articleView?id=sf.custommetadatatypes_overview.htm)

---

## 🎯 Résumé des fichiers

```
scripts/apex/
├── README.md                           # Ce fichier
├── testAllSAPServices.apex             # ⭐ TEST CONSOLIDÉ (tous les services)
├── testSAPEndpointService.apex         # Test Service GreenAlp (Détails Point)
├── testSAPBTPActivation.apex           # Test Service Activation (CSRF Token)
├── testSAPProductCatalog.apex          # Test Service des Produits (Catalogue)
├── listNamedCredentials.apex           # Lister tous les Named Credentials
├── SAPDetailPointServiceCallout        # Classe pour Service GreenAlp
├── CallSAPBTPEndpointQueueable         # Classe pour Service Activation
└── ProductCatalogService.txt           # Documentation External Service
```

**Recommandation :** Utilisez `testAllSAPServices.apex` pour une vue d'ensemble complète, ou les scripts individuels pour des tests ciblés.

---

**Dernière mise à jour :** Novembre 2025
