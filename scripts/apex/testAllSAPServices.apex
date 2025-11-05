/**
 * ╔════════════════════════════════════════════════════════════════════════╗
 * ║  SCRIPT DE TEST COMPLET - TOUS LES NAMED CREDENTIALS SAP              ║
 * ╚════════════════════════════════════════════════════════════════════════╝
 *
 * Ce script teste les 3 Named Credentials SAP en une seule exécution :
 * 1. SAP BTP HTTP (Service Activation)
 * 2. SAP Endpoint Service (Service GreenAlp)
 * 3. SAP Product Catalog Service (Service des Produits)
 *
 * PARAMÈTRES À ADAPTER :
 * - Ligne ~50  : Point ID pour Service GreenAlp
 * - Ligne ~51  : Login utilisateur pour Service GreenAlp
 * - Ligne ~150 : CITY_CODE et autres paramètres pour Product Catalog
 *
 * EXÉCUTION :
 * - Via Developer Console : Debug > Open Execute Anonymous Window
 * - Via SF CLI : sf apex run -f scripts/apex/testAllSAPServices.apex -o origame5-dev
 */

// Récupérer les informations de l'org
Organization org = [SELECT Name, IsSandbox, InstanceName, OrganizationType FROM Organization LIMIT 1];
String orgInfo = org.Name;
if (org.IsSandbox) {
    // Récupérer le nom du sandbox depuis l'URL (ex: origame5)
    String baseUrl = URL.getOrgDomainUrl().toExternalForm();
    if (baseUrl.contains('--')) {
        String sandboxName = baseUrl.substringBetween('--', '.').substringBefore('.sandbox');
        if (String.isNotBlank(sandboxName)) {
            orgInfo = orgInfo + ' (Sandbox: ' + sandboxName + ')';
        } else {
            orgInfo = orgInfo + ' (Sandbox)';
        }
    } else {
        orgInfo = orgInfo + ' (Sandbox)';
    }
} else {
    orgInfo = orgInfo + ' (Production)';
}

System.debug('\n\n');
System.debug('╔════════════════════════════════════════════════════════════════════════╗');
System.debug('║                                                                        ║');
System.debug('║           TEST COMPLET DES NAMED CREDENTIALS SAP - DÉBUT              ║');
System.debug('║                                                                        ║');
System.debug('╚════════════════════════════════════════════════════════════════════════╝');
System.debug('\n');
System.debug('Date/Heure du test : ' + System.now());
System.debug('Environnement      : ' + orgInfo);
System.debug('Type d\'org         : ' + org.OrganizationType);
System.debug('Instance           : ' + org.InstanceName);
System.debug('\n');

// Variables pour tracker les résultats
Map<String, String> testResults = new Map<String, String>();
Integer totalTests = 4;
Integer successCount = 0;
Integer failureCount = 0;

// ============================================================================
// TEST 1/4 : SAP BTP HTTP (SERVICE ACTIVATION)
// ============================================================================

System.debug('\n');
System.debug('╔════════════════════════════════════════════════════════════════════════╗');
System.debug('║  TEST 1/4 : SAP BTP HTTP - SERVICE ACTIVATION                         ║');
System.debug('╚════════════════════════════════════════════════════════════════════════╝');
System.debug('\n');
System.debug('Named Credential : SAP BTP http');
System.debug('Méthode          : GET (récupération CSRF token)');
System.debug('Configuration    : Custom Metadata SAP_IntegrationSettings__mdt');
System.debug('\n');

try {
    // Récupérer les settings depuis Custom Metadata Type
    List<SAP_IntegrationSettings__mdt> settingsList = [
        SELECT Endpoint__c, Username__c, Password__c, MasterLabel
        FROM SAP_IntegrationSettings__mdt
        LIMIT 1
    ];

    if (settingsList.isEmpty()) {
        System.debug('✗ ÉCHEC : Aucun enregistrement SAP_IntegrationSettings__mdt trouvé');
        testResults.put('SAP BTP HTTP', 'ÉCHEC - Custom Metadata manquant');
        failureCount++;
    } else {
        SAP_IntegrationSettings__mdt settings = settingsList[0];

        if (String.isBlank(settings.Endpoint__c) || String.isBlank(settings.Username__c) || String.isBlank(settings.Password__c)) {
            System.debug('✗ ÉCHEC : Champs manquants dans SAP_IntegrationSettings__mdt');
            testResults.put('SAP BTP HTTP', 'ÉCHEC - Configuration incomplète');
            failureCount++;
        } else {
            System.debug('Configuration : ' + settings.MasterLabel);
            System.debug('Endpoint      : ' + settings.Endpoint__c);
            System.debug('\n');

            // GET pour récupérer le CSRF token
            HttpRequest req = new HttpRequest();
            req.setEndpoint(settings.Endpoint__c);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-csrf-token', 'Fetch');

            Blob headerValue = Blob.valueOf(settings.Username__c + ':' + settings.Password__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);

            Http http = new Http();
            HttpResponse res = http.send(req);

            Integer statusCode = res.getStatusCode();
            String csrfToken = res.getHeader('x-csrf-token');

            System.debug('Status Code : ' + statusCode);

            if (statusCode >= 200 && statusCode < 300) {
                System.debug('✓ SUCCÈS - Connexion établie');
                if (String.isNotBlank(csrfToken)) {
                    System.debug('✓ CSRF Token récupéré : ' + csrfToken);
                }
                testResults.put('SAP BTP HTTP', 'SUCCÈS');
                successCount++;
            } else {
                System.debug('✗ ÉCHEC - Status Code : ' + statusCode);
                System.debug('Message : ' + res.getStatus());
                testResults.put('SAP BTP HTTP', 'ÉCHEC - HTTP ' + statusCode);
                failureCount++;
            }
        }
    }
} catch (Exception e) {
    System.debug('✗ ERREUR : ' + e.getMessage());
    testResults.put('SAP BTP HTTP', 'ERREUR - ' + e.getTypeName());
    failureCount++;
}

// ============================================================================
// TEST 2/4 : SAP ENDPOINT SERVICE (SERVICE GREENALP)
// ============================================================================

System.debug('\n\n');
System.debug('╔════════════════════════════════════════════════════════════════════════╗');
System.debug('║  TEST 2/4 : SAP ENDPOINT SERVICE - SERVICE GREENALP                   ║');
System.debug('╚════════════════════════════════════════════════════════════════════════╝');
System.debug('\n');
System.debug('Named Credential : SAP_Endpoint_Service');
System.debug('Méthode          : POST (détails point de livraison)');
System.debug('Classe utilisée  : SAPDetailPointServiceCallout');
System.debug('\n');

// ⚠️ PARAMÈTRES À ADAPTER
String pointId = '125278EC1';
String loginUtilisateur = 'khawla.trimeche@iliadeconsulting.com';
Boolean contratConcluNouveauClientSurSite = false;
Boolean autorisationClient = true;

System.debug('Paramètres :');
System.debug('- Point ID            : ' + pointId);
System.debug('- Login Utilisateur   : ' + loginUtilisateur);
System.debug('\n');

try {
    SAPDetailPointServiceCallout.DonneesDemandees donnees =
        new SAPDetailPointServiceCallout.DonneesDemandees();
    donnees.donneesGeneralesPoint = true;
    donnees.derniersIndex = true;

    SAPDetailPointServiceCallout.SAPResponse response =
        SAPDetailPointServiceCallout.callSAP(
            pointId,
            loginUtilisateur,
            donnees,
            contratConcluNouveauClientSurSite,
            autorisationClient
        );

    System.debug('Status Code : ' + response.responseCode);

    if (response.isSuccess) {
        System.debug('✓ SUCCÈS - Données du point récupérées');
        if (response.data != null) {
            Map<String, Object> data = (Map<String, Object>) response.data;
            System.debug('Clés retournées : ' + data.keySet());
        }
        testResults.put('SAP Endpoint Service', 'SUCCÈS');
        successCount++;
    } else {
        System.debug('✗ ÉCHEC - ' + response.defaultValue);
        testResults.put('SAP Endpoint Service', 'ÉCHEC - ' + response.responseCode);
        failureCount++;
    }
} catch (Exception e) {
    System.debug('✗ ERREUR : ' + e.getMessage());
    testResults.put('SAP Endpoint Service', 'ERREUR - ' + e.getTypeName());
    failureCount++;
}

// ============================================================================
// TEST 3/4 : SAP PRODUCT CATALOG SERVICE (SERVICE DES PRODUITS)
// ============================================================================

System.debug('\n\n');
System.debug('╔════════════════════════════════════════════════════════════════════════╗');
System.debug('║  TEST 3/4 : SAP PRODUCT CATALOG SERVICE - SERVICE DES PRODUITS        ║');
System.debug('╚════════════════════════════════════════════════════════════════════════╝');
System.debug('\n');
System.debug('Named Credential : SAP_Product_Catalog_Service');
System.debug('Méthode          : POST (recherche produits)');
System.debug('Action           : ProductCatalogInvocable');
System.debug('\n');

// ⚠️ PARAMÈTRES À ADAPTER (basés sur un appel réel qui fonctionne)
Map<String, Object> requestBody = new Map<String, Object>{
    'CITY_CODE' => '69387',        // Code INSEE de la commune
    'ENERGY' => '01',               // 01=Electricité, 02=Gaz
    'UIL_USAGE' => 'DOM',           // DOM=Domestique, PRO=Professionnel
    'CAR' => '4\u202f500',          // CAR (puissance) avec espace insécable
    'GREEN_OPTION' => 'FOR',        // Option verte : FOR, ECO, etc.
    'GREEN_RATE' => '100',          // Taux vert en %
    'SERVICE_OPT' => '0xf926425',   // Code des options de service
    'REFDATE' => DateTime.now().format('yyyyMMdd') // Date au format YYYYMMDD
};

System.debug('Paramètres :');
System.debug('- CITY_CODE  : ' + requestBody.get('CITY_CODE'));
System.debug('- ENERGY     : ' + requestBody.get('ENERGY'));
System.debug('- PS         : ' + requestBody.get('PS'));
System.debug('- OPT_TARIF  : ' + requestBody.get('OPT_TARIF'));
System.debug('\n');

try {
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:SAP_Product_Catalog_Service');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Accept', 'application/json');
    req.setBody(JSON.serialize(requestBody));

    Http http = new Http();
    HttpResponse res = http.send(req);

    Integer statusCode = res.getStatusCode();
    System.debug('Status Code : ' + statusCode);

    if (statusCode >= 200 && statusCode < 300) {
        System.debug('✓ SUCCÈS - Catalogue produits récupéré');

        String responseBody = res.getBody();
        if (String.isNotBlank(responseBody)) {
            try {
                List<Object> products = (List<Object>) JSON.deserializeUntyped(responseBody);
                System.debug('Nombre de produits retournés : ' + products.size());
            } catch (Exception je) {
                System.debug('Réponse reçue mais format inattendu');
            }
        }
        testResults.put('SAP Product Catalog', 'SUCCÈS');
        successCount++;
    } else {
        System.debug('✗ ÉCHEC - Status Code : ' + statusCode);
        System.debug('Message : ' + res.getStatus());
        testResults.put('SAP Product Catalog', 'ÉCHEC - HTTP ' + statusCode);
        failureCount++;
    }
} catch (Exception e) {
    System.debug('✗ ERREUR : ' + e.getMessage());
    testResults.put('SAP Product Catalog', 'ERREUR - ' + e.getTypeName());
    failureCount++;
}

// ============================================================================
// TEST 4/4 : SAP EXTERNAL DATA SOURCE (SALESFORCE CONNECT ODATA)
// ============================================================================

System.debug('\n\n');
System.debug('╔════════════════════════════════════════════════════════════════════════╗');
System.debug('║  TEST 4/4 : SAP EXTERNAL DATA SOURCE - SALESFORCE CONNECT             ║');
System.debug('╚════════════════════════════════════════════════════════════════════════╝');
System.debug('\n');
System.debug('Type             : Salesforce Connect (OData 2.0)');
System.debug('Source de données: SAP');
System.debug('Objet externe    : SAPContract__x');
System.debug('URL              : https://geg-api.test.apimanagement.eu10.hana.ondemand.com/ZAPI_SAP_SF_V2_DF1');
System.debug('\n');

try {
    System.debug('Test de connexion via requête SOQL sur objet externe...');
    System.debug('\n');

    // Requête SOQL sur l'objet externe - Salesforce utilise automatiquement
    // les credentials configurés dans External Data Source
    List<SAPContract__x> contracts = [SELECT ExternalId FROM SAPContract__x LIMIT 1];

    System.debug('✓ SUCCÈS - Connexion OData opérationnelle');
    System.debug('Nombre d\'enregistrements récupérés : ' + contracts.size());

    if (!contracts.isEmpty()) {
        System.debug('Exemple d\'ExternalId récupéré : ' + contracts[0].ExternalId);
    }

    testResults.put('SAP OData Connect', 'SUCCÈS');
    successCount++;

} catch (System.QueryException e) {
    System.debug('✗ ÉCHEC - Erreur de requête SOQL');
    System.debug('Message : ' + e.getMessage());
    System.debug('\n→ SOLUTIONS POSSIBLES:');

    if (e.getMessage().contains('External Object is currently not writable or readable')) {
        System.debug('  - L\'External Data Source "SAP" n\'est pas accessible');
        System.debug('  - Vérifier que la source de données est validée et synchronisée');
        System.debug('  - Setup > External Data Sources > SAP > Validate and Sync');
    } else if (e.getMessage().contains('No such column')) {
        System.debug('  - L\'objet externe SAPContract__x n\'est pas synchronisé');
        System.debug('  - Allez dans Setup > External Objects > SAPContract__x');
        System.debug('  - Vérifier les champs disponibles');
    } else if (e.getMessage().contains('401') || e.getMessage().contains('Unauthorized')) {
        System.debug('  - Problème d\'authentification avec SAP');
        System.debug('  - Vérifier les credentials dans External Data Source "SAP"');
        System.debug('  - Utilisateur : SFDC_CPI');
        System.debug('  - Vérifier que le mot de passe est à jour');
    } else if (e.getMessage().contains('timeout') || e.getMessage().contains('timed out')) {
        System.debug('  - Le service SAP OData ne répond pas');
        System.debug('  - Vérifier la connectivité réseau');
        System.debug('  - Vérifier que le service SAP est opérationnel');
    } else {
        System.debug('  - Erreur générique de connexion OData');
        System.debug('  - Vérifier l\'External Data Source dans Setup');
        System.debug('  - Vérifier les Remote Site Settings');
    }

    testResults.put('SAP OData Connect', 'ÉCHEC - Query Error');
    failureCount++;

} catch (Exception e) {
    System.debug('✗ ERREUR INATTENDUE');
    System.debug('Type : ' + e.getTypeName());
    System.debug('Message : ' + e.getMessage());
    testResults.put('SAP OData Connect', 'ERREUR - ' + e.getTypeName());
    failureCount++;
}

// ============================================================================
// RÉSUMÉ FINAL
// ============================================================================

System.debug('\n\n');
System.debug('╔════════════════════════════════════════════════════════════════════════╗');
System.debug('║                      RÉSUMÉ DES TESTS                                  ║');
System.debug('╚════════════════════════════════════════════════════════════════════════╝');
System.debug('\n');

System.debug('┌────────────────────────────────────────────────────────────────────┐');
System.debug('│ SERVICE                      │ NAMED CREDENTIAL           │ RÉSULTAT │');
System.debug('├────────────────────────────────────────────────────────────────────┤');

// Test 1
String result1 = testResults.get('SAP BTP HTTP');
String icon1 = result1.startsWith('SUCCÈS') ? '✓' : '✗';
String padding1 = ' '.repeat(Math.max(0, 28 - 'Service Activation'.length()));
String padding1b = ' '.repeat(Math.max(0, 26 - 'SAP BTP http'.length()));
String padding1c = ' '.repeat(Math.max(0, 8 - result1.length()));
System.debug('│ Service Activation' + padding1 + ' │ SAP BTP http' + padding1b + ' │ ' + icon1 + ' ' + result1 + padding1c + ' │');

// Test 2
String result2 = testResults.get('SAP Endpoint Service');
String icon2 = result2.startsWith('SUCCÈS') ? '✓' : '✗';
String padding2 = ' '.repeat(Math.max(0, 28 - 'Service GreenAlp'.length()));
String padding2b = ' '.repeat(Math.max(0, 26 - 'SAP_Endpoint_Service'.length()));
String padding2c = ' '.repeat(Math.max(0, 8 - result2.length()));
System.debug('│ Service GreenAlp' + padding2 + ' │ SAP_Endpoint_Service' + padding2b + ' │ ' + icon2 + ' ' + result2 + padding2c + ' │');

// Test 3
String result3 = testResults.get('SAP Product Catalog');
String icon3 = result3.startsWith('SUCCÈS') ? '✓' : '✗';
String padding3 = ' '.repeat(Math.max(0, 28 - 'Service des Produits'.length()));
String padding3b = ' '.repeat(Math.max(0, 26 - 'SAP_Product_Catalog_Service'.length()));
String padding3c = ' '.repeat(Math.max(0, 8 - result3.length()));
System.debug('│ Service des Produits' + padding3 + ' │ SAP_Product_Catalog_Service' + padding3b + '│ ' + icon3 + ' ' + result3 + padding3c + ' │');

// Test 4
String result4 = testResults.get('SAP OData Connect');
String icon4 = result4.startsWith('SUCCÈS') ? '✓' : '✗';
String padding4 = ' '.repeat(Math.max(0, 28 - 'OData / Salesforce Connect'.length()));
String padding4b = ' '.repeat(Math.max(0, 26 - 'External Data Source SAP'.length()));
String padding4c = ' '.repeat(Math.max(0, 8 - result4.length()));
System.debug('│ OData / Salesforce Connect' + padding4 + ' │ External Data Source SAP' + padding4b + ' │ ' + icon4 + ' ' + result4 + padding4c + ' │');

System.debug('└────────────────────────────────────────────────────────────────────┘');
System.debug('\n');

// Statistiques
System.debug('STATISTIQUES :');
System.debug('- Total de tests   : ' + totalTests);
System.debug('- Succès           : ' + successCount + ' (' + ((successCount * 100) / totalTests) + '%)');
System.debug('- Échecs           : ' + failureCount + ' (' + ((failureCount * 100) / totalTests) + '%)');
System.debug('\n');

// Verdict final
if (successCount == totalTests) {
    System.debug('╔════════════════════════════════════════════════════════════════════════╗');
    System.debug('║  ✓✓✓ TOUTES LES CONNEXIONS SAP SONT OPÉRATIONNELLES ✓✓✓              ║');
    System.debug('╚════════════════════════════════════════════════════════════════════════╝');
} else if (successCount > 0) {
    System.debug('╔════════════════════════════════════════════════════════════════════════╗');
    System.debug('║  ⚠ ATTENTION : CERTAINES CONNEXIONS SAP ONT DES PROBLÈMES             ║');
    System.debug('╚════════════════════════════════════════════════════════════════════════╝');
    System.debug('\nActions recommandées :');
    if (testResults.get('SAP BTP HTTP') != 'SUCCÈS') {
        System.debug('- SAP BTP HTTP : Vérifier le Custom Metadata SAP_IntegrationSettings__mdt');
    }
    if (testResults.get('SAP Endpoint Service') != 'SUCCÈS') {
        System.debug('- SAP Endpoint Service : Vérifier le Point ID et les credentials');
    }
    if (testResults.get('SAP Product Catalog') != 'SUCCÈS') {
        System.debug('- SAP Product Catalog : Vérifier les paramètres de recherche');
    }
    if (testResults.get('SAP OData Connect') != 'SUCCÈS') {
        System.debug('- SAP OData Connect : Setup > External Data Sources > SAP > Validate and Sync');
    }
} else {
    System.debug('╔════════════════════════════════════════════════════════════════════════╗');
    System.debug('║  ✗✗✗ AUCUNE CONNEXION SAP N\'EST OPÉRATIONNELLE ✗✗✗                   ║');
    System.debug('╚════════════════════════════════════════════════════════════════════════╝');
    System.debug('\nActions recommandées :');
    System.debug('- Vérifier les Remote Site Settings');
    System.debug('- Vérifier les Named Credentials dans Setup');
    System.debug('- Vérifier les External Credentials associés');
    System.debug('- Vérifier l\'External Data Source SAP (Salesforce Connect)');
    System.debug('- Consulter la documentation dans scripts/apex/README.md');
}

System.debug('\n');
System.debug('╔════════════════════════════════════════════════════════════════════════╗');
System.debug('║           TEST COMPLET DES NAMED CREDENTIALS SAP - FIN                ║');
System.debug('╚════════════════════════════════════════════════════════════════════════╝');
System.debug('\n');
System.debug('Pour plus de détails sur chaque test, consultez les logs ci-dessus.');
System.debug('Pour des tests individuels, utilisez les scripts spécifiques :');
System.debug('- testSAPBTPActivation.apex');
System.debug('- testSAPEndpointService.apex');
System.debug('- testSAPProductCatalog.apex');
