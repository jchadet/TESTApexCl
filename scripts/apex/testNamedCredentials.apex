/**
 * Script Apex Anonymous pour tester les Named Credentials SAP
 *
 * Ce script teste les 3 Named Credentials configurés pour les callouts SAP :
 * 1. SAP BTP http
 * 2. SAP Endpoint Service
 * 3. SAP Product Catalog Service
 *
 * IMPORTANT: Remplacez les noms des Named Credentials (ligne ~25, ~80, ~135)
 * par les noms exacts de votre org avant d'exécuter ce script.
 *
 * Exécution :
 * - Via Developer Console : Debug > Open Execute Anonymous Window
 * - Via SF CLI : sf apex run -f testNamedCredentials.apex -o origame5-dev
 */

System.debug('\n');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('║     TEST DES NAMED CREDENTIALS SAP - DÉBUT                     ║');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('\n');

// ============================================================================
// TEST 1: SAP BTP http
// Endpoint: https://geg-distributeur-dev.it-cpi024-rt.cfapps.eu10-002.hana.ondemand.com/http/DF/SalesForce/activation
// ============================================================================

String namedCredential1 = 'SAP_BTP_http';  // ⚠️ REMPLACER par le nom exact
System.debug('========================================');
System.debug('Test du Named Credential: ' + namedCredential1);
System.debug('========================================');

try {
    String endpoint1 = 'callout:' + namedCredential1;
    System.debug('Endpoint: ' + endpoint1);
    System.debug('Méthode HTTP: GET');

    HttpRequest req1 = new HttpRequest();
    req1.setEndpoint(endpoint1);
    req1.setMethod('GET');
    req1.setTimeout(120000);
    req1.setHeader('Content-Type', 'application/json');
    req1.setHeader('Accept', 'application/json');

    Http http1 = new Http();
    HttpResponse res1 = http1.send(req1);

    Integer statusCode1 = res1.getStatusCode();
    String status1 = res1.getStatus();
    String responseBody1 = res1.getBody();

    System.debug('Status Code: ' + statusCode1);
    System.debug('Status: ' + status1);

    if (statusCode1 >= 200 && statusCode1 < 300) {
        System.debug('✓ SUCCÈS - Named Credential configuré correctement');
    } else if (statusCode1 == 401 || statusCode1 == 403) {
        System.debug('✗ ÉCHEC - Erreur d\'authentification (vérifier External Credential)');
    } else if (statusCode1 == 404) {
        System.debug('⚠ AVERTISSEMENT - Endpoint non trouvé (vérifier l\'URL)');
    } else if (statusCode1 >= 500) {
        System.debug('✗ ÉCHEC - Erreur serveur SAP');
    } else {
        System.debug('⚠ AVERTISSEMENT - Status code inattendu: ' + statusCode1);
    }

    if (String.isNotBlank(responseBody1)) {
        String bodyPreview1 = responseBody1.length() > 500 ?
            responseBody1.substring(0, 500) + '...' : responseBody1;
        System.debug('Réponse (preview): ' + bodyPreview1);
    }

} catch (System.CalloutException e) {
    System.debug('✗ ÉCHEC - Erreur de callout: ' + e.getMessage());
    if (e.getMessage().contains('Unauthorized endpoint')) {
        System.debug('→ Solution: Vérifier les Remote Site Settings');
    } else if (e.getMessage().contains('Invalid named credential')) {
        System.debug('→ Solution: Vérifier que le Named Credential existe et est actif');
    }
} catch (Exception e) {
    System.debug('✗ ÉCHEC - Erreur inattendue: ' + e.getMessage());
    System.debug('Type: ' + e.getTypeName());
}

System.debug('');

// ============================================================================
// TEST 2: SAP Endpoint Service
// Endpoint: https://geg-api.test.apimanagement.eu10.hana.ondemand.com:443/DG
// ============================================================================

String namedCredential2 = 'SAP_Endpoint_Service';  // ⚠️ REMPLACER par le nom exact
System.debug('========================================');
System.debug('Test du Named Credential: ' + namedCredential2);
System.debug('========================================');

try {
    String endpoint2 = 'callout:' + namedCredential2;
    System.debug('Endpoint: ' + endpoint2);
    System.debug('Méthode HTTP: GET');

    HttpRequest req2 = new HttpRequest();
    req2.setEndpoint(endpoint2);
    req2.setMethod('GET');
    req2.setTimeout(120000);
    req2.setHeader('Content-Type', 'application/json');
    req2.setHeader('Accept', 'application/json');

    Http http2 = new Http();
    HttpResponse res2 = http2.send(req2);

    Integer statusCode2 = res2.getStatusCode();
    String status2 = res2.getStatus();
    String responseBody2 = res2.getBody();

    System.debug('Status Code: ' + statusCode2);
    System.debug('Status: ' + status2);

    if (statusCode2 >= 200 && statusCode2 < 300) {
        System.debug('✓ SUCCÈS - Named Credential configuré correctement');
    } else if (statusCode2 == 401 || statusCode2 == 403) {
        System.debug('✗ ÉCHEC - Erreur d\'authentification (vérifier External Credential)');
    } else if (statusCode2 == 404) {
        System.debug('⚠ AVERTISSEMENT - Endpoint non trouvé (vérifier l\'URL)');
    } else if (statusCode2 >= 500) {
        System.debug('✗ ÉCHEC - Erreur serveur SAP');
    } else {
        System.debug('⚠ AVERTISSEMENT - Status code inattendu: ' + statusCode2);
    }

    if (String.isNotBlank(responseBody2)) {
        String bodyPreview2 = responseBody2.length() > 500 ?
            responseBody2.substring(0, 500) + '...' : responseBody2;
        System.debug('Réponse (preview): ' + bodyPreview2);
    }

} catch (System.CalloutException e) {
    System.debug('✗ ÉCHEC - Erreur de callout: ' + e.getMessage());
    if (e.getMessage().contains('Unauthorized endpoint')) {
        System.debug('→ Solution: Vérifier les Remote Site Settings');
    } else if (e.getMessage().contains('Invalid named credential')) {
        System.debug('→ Solution: Vérifier que le Named Credential existe et est actif');
    }
} catch (Exception e) {
    System.debug('✗ ÉCHEC - Erreur inattendue: ' + e.getMessage());
    System.debug('Type: ' + e.getTypeName());
}

System.debug('');

// ============================================================================
// TEST 3: SAP Product Catalog Service
// Endpoint: https://geg-api.test.apimanagement.eu10.hana.ondemand.com:443/DF/ProductCatalog
// ============================================================================

String namedCredential3 = 'SAP_Product_Catalog_Service';  // ⚠️ REMPLACER par le nom exact
System.debug('========================================');
System.debug('Test du Named Credential: ' + namedCredential3);
System.debug('========================================');

try {
    String endpoint3 = 'callout:' + namedCredential3;
    System.debug('Endpoint: ' + endpoint3);
    System.debug('Méthode HTTP: GET');

    HttpRequest req3 = new HttpRequest();
    req3.setEndpoint(endpoint3);
    req3.setMethod('GET');
    req3.setTimeout(120000);
    req3.setHeader('Content-Type', 'application/json');
    req3.setHeader('Accept', 'application/json');

    Http http3 = new Http();
    HttpResponse res3 = http3.send(req3);

    Integer statusCode3 = res3.getStatusCode();
    String status3 = res3.getStatus();
    String responseBody3 = res3.getBody();

    System.debug('Status Code: ' + statusCode3);
    System.debug('Status: ' + status3);

    if (statusCode3 >= 200 && statusCode3 < 300) {
        System.debug('✓ SUCCÈS - Named Credential configuré correctement');
    } else if (statusCode3 == 401 || statusCode3 == 403) {
        System.debug('✗ ÉCHEC - Erreur d\'authentification (vérifier External Credential)');
    } else if (statusCode3 == 404) {
        System.debug('⚠ AVERTISSEMENT - Endpoint non trouvé (vérifier l\'URL)');
    } else if (statusCode3 >= 500) {
        System.debug('✗ ÉCHEC - Erreur serveur SAP');
    } else {
        System.debug('⚠ AVERTISSEMENT - Status code inattendu: ' + statusCode3);
    }

    if (String.isNotBlank(responseBody3)) {
        String bodyPreview3 = responseBody3.length() > 500 ?
            responseBody3.substring(0, 500) + '...' : responseBody3;
        System.debug('Réponse (preview): ' + bodyPreview3);
    }

} catch (System.CalloutException e) {
    System.debug('✗ ÉCHEC - Erreur de callout: ' + e.getMessage());
    if (e.getMessage().contains('Unauthorized endpoint')) {
        System.debug('→ Solution: Vérifier les Remote Site Settings');
    } else if (e.getMessage().contains('Invalid named credential')) {
        System.debug('→ Solution: Vérifier que le Named Credential existe et est actif');
    }
} catch (Exception e) {
    System.debug('✗ ÉCHEC - Erreur inattendue: ' + e.getMessage());
    System.debug('Type: ' + e.getTypeName());
}

System.debug('\n');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('║     TEST DES NAMED CREDENTIALS SAP - FIN                       ║');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('\n');

System.debug('INFORMATIONS:');
System.debug('- Les Named Credentials utilisent les External Credentials pour l\'authentification');
System.debug('- Vérifier que les Named Credentials sont bien nommés (remplacer les underscores si nécessaire)');
System.debug('- Adapter les méthodes HTTP (GET/POST) selon vos besoins réels');
System.debug('- Pour plus de détails, activer le niveau de log "FINEST" pour System.debug');
