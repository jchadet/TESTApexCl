/**
 * Version SIMPLIFIÉE du test des Named Credentials SAP
 *
 * INSTRUCTIONS AVANT EXÉCUTION:
 * 1. Remplacez 'Nom_Exact_Named_Credential' par les vrais noms de vos Named Credentials
 * 2. Les noms exacts se trouvent dans Setup > Named Credentials (colonne "Name" ou "Developer Name")
 * 3. Exécutez ce script via Developer Console ou SF CLI
 */

// ============================================================================
// TEST 1: SAP BTP http
// ============================================================================
System.debug('\n=== TEST 1: SAP BTP http ===');
try {
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:SAP_BTP_http');  // ⚠️ REMPLACER par le nom exact
    req.setMethod('GET');
    req.setTimeout(120000);
    req.setHeader('Content-Type', 'application/json');

    Http http = new Http();
    HttpResponse res = http.send(req);

    System.debug('Status Code: ' + res.getStatusCode());
    System.debug('Status: ' + res.getStatus());

    if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
        System.debug('✓ SUCCÈS - Named Credential configuré correctement');
    } else {
        System.debug('✗ ÉCHEC - Code: ' + res.getStatusCode());
    }
} catch (Exception e) {
    System.debug('✗ ERREUR: ' + e.getMessage());
}

// ============================================================================
// TEST 2: SAP Endpoint Service
// ============================================================================
System.debug('\n=== TEST 2: SAP Endpoint Service ===');
try {
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:SAP_Endpoint_Service');  // ⚠️ REMPLACER par le nom exact
    req.setMethod('GET');
    req.setTimeout(120000);
    req.setHeader('Content-Type', 'application/json');

    Http http = new Http();
    HttpResponse res = http.send(req);

    System.debug('Status Code: ' + res.getStatusCode());
    System.debug('Status: ' + res.getStatus());

    if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
        System.debug('✓ SUCCÈS - Named Credential configuré correctement');
    } else {
        System.debug('✗ ÉCHEC - Code: ' + res.getStatusCode());
    }
} catch (Exception e) {
    System.debug('✗ ERREUR: ' + e.getMessage());
}

// ============================================================================
// TEST 3: SAP Product Catalog Service
// ============================================================================
System.debug('\n=== TEST 3: SAP Product Catalog Service ===');
try {
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:SAP_Product_Catalog_Service');  // ⚠️ REMPLACER par le nom exact
    req.setMethod('GET');
    req.setTimeout(120000);
    req.setHeader('Content-Type', 'application/json');

    Http http = new Http();
    HttpResponse res = http.send(req);

    System.debug('Status Code: ' + res.getStatusCode());
    System.debug('Status: ' + res.getStatus());

    if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
        System.debug('✓ SUCCÈS - Named Credential configuré correctement');
    } else {
        System.debug('✗ ÉCHEC - Code: ' + res.getStatusCode());
    }
} catch (Exception e) {
    System.debug('✗ ERREUR: ' + e.getMessage());
}

System.debug('\n=== FIN DES TESTS ===\n');
