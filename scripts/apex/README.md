# Test des Named Credentials SAP

Ce dossier contient un script Apex anonymous pour tester les Named Credentials configurés pour les callouts SAP.

## Named Credentials testés

1. **SAP BTP http**
   - Endpoint: `https://geg-distributeur-dev.it-cpi024-rt.cfapps.eu10-002.hana.ondemand.com/http/DF/SalesForce/activation`
   - External Credential: SAP BTP HTTP External Credential

2. **SAP Endpoint Service**
   - Endpoint: `https://geg-api.test.apimanagement.eu10.hana.ondemand.com:443/DG`
   - External Credential: SAP Endpoint ExternalService

3. **SAP Product Catalog Service**
   - Endpoint: `https://geg-api.test.apimanagement.eu10.hana.ondemand.com:443/DF/ProductCatalog`
   - External Credential: ProductCatalogExternalService

## Préparation

### 1. Vérifier les noms exacts des Named Credentials

Avant d'exécuter le script, vous devez vérifier les noms **exacts** de vos Named Credentials dans Salesforce :

1. Allez dans **Setup** > **Named Credentials**
2. Notez les noms API exacts (DeveloperName) de vos 3 Named Credentials
3. Ouvrez le fichier `testNamedCredentials.apex`
4. Remplacez les noms dans les appels de fonction :
   - `'SAP_BTP_http'` → remplacer par le nom exact
   - `'SAP_Endpoint_Service'` → remplacer par le nom exact
   - `'SAP_Product_Catalog_Service'` → remplacer par le nom exact

### 2. Adapter les méthodes HTTP

Par défaut, le script utilise la méthode `GET`. Si vos endpoints SAP nécessitent d'autres méthodes (POST, PUT, etc.), modifiez les appels :

```apex
NamedCredentialTester.testNamedCredential(
    'Votre_Named_Credential',
    '',
    'POST'  // Changer ici : GET, POST, PUT, PATCH, DELETE
);
```

## Exécution du script

### Option 1 : Via Developer Console (Interface Web)

1. Dans Salesforce, appuyez sur **F12** ou allez dans **Developer Console**
2. Cliquez sur **Debug** > **Open Execute Anonymous Window**
3. Copiez tout le contenu du fichier `testNamedCredentials.apex`
4. Collez-le dans la fenêtre
5. Cochez **Open Log**
6. Cliquez sur **Execute**
7. Consultez les logs pour voir les résultats

### Option 2 : Via SF CLI (Ligne de commande)

```bash
sf apex run -f scripts/apex/testNamedCredentials.apex -o origame5-dev
```

## Interprétation des résultats

Le script affiche des symboles pour indiquer le statut de chaque test :

- **✓ SUCCÈS** : Named Credential configuré correctement (HTTP 200-299)
- **✗ ÉCHEC** : Problème de configuration ou d'authentification
- **⚠ AVERTISSEMENT** : Le callout fonctionne mais retourne un code inattendu

### Codes de statut HTTP courants

| Code | Signification | Action à prendre |
|------|---------------|------------------|
| 200-299 | Succès | Named Credential OK |
| 401 | Non autorisé | Vérifier l'External Credential (username/password/token) |
| 403 | Interdit | Vérifier les permissions SAP |
| 404 | Non trouvé | Vérifier l'URL de l'endpoint |
| 500-599 | Erreur serveur SAP | Contacter l'équipe SAP |

### Erreurs de callout

Si vous voyez `Unauthorized endpoint`, ajoutez l'URL dans **Remote Site Settings** :

1. **Setup** > **Remote Site Settings**
2. Cliquez sur **New Remote Site**
3. Ajoutez l'URL de base SAP

## Personnalisation du script

### Ajouter des en-têtes personnalisés

Dans la fonction `testNamedCredential`, ajoutez :

```apex
req.setHeader('Custom-Header', 'Valeur');
```

### Ajouter un body pour POST/PUT

Modifiez la section body :

```apex
if (httpMethod == 'POST' || httpMethod == 'PUT') {
    String body = JSON.serialize(new Map<String, Object>{
        'key' => 'value'
    });
    req.setBody(body);
}
```

### Tester avec des paramètres d'URL

Utilisez le deuxième paramètre pour ajouter des paramètres :

```apex
NamedCredentialTester.testNamedCredential(
    'SAP_Product_Catalog_Service',
    '/products?limit=10',  // Ajouter des paramètres
    'GET'
);
```

## Troubleshooting

### Problème : "Invalid named credential"
**Solution** : Vérifier le nom exact du Named Credential (sensible à la casse)

### Problème : "Unauthorized endpoint"
**Solution** : Ajouter l'URL dans Remote Site Settings

### Problème : "Read timed out"
**Solution** : Le serveur SAP ne répond pas, vérifier la connectivité réseau

### Problème : HTTP 401/403
**Solution** : Vérifier l'External Credential (credentials invalides ou expirés)

## Support

Pour toute question, consulter la documentation Salesforce :
- [Named Credentials](https://help.salesforce.com/articleView?id=sf.named_credentials_about.htm)
- [External Credentials](https://help.salesforce.com/articleView?id=sf.external_credentials_about.htm)
