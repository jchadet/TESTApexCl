/**
 * Script Apex Anonymous pour tester SAP Product Catalog Service
 *
 * Ce script teste le Named Credential SAP_Product_Catalog_Service
 * en appelant l'action ProductCatalogInvocable
 *
 * IMPORTANT: Adaptez les valeurs de test selon vos besoins
 *
 * Exécution :
 * - Via Developer Console : Debug > Open Execute Anonymous Window
 * - Via SF CLI : sf apex run -f scripts/apex/testSAPProductCatalog.apex -o origame5-dev
 */

System.debug('\n');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('║     TEST SAP PRODUCT CATALOG SERVICE - DÉBUT                   ║');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('\n');

// ============================================================================
// PARAMÈTRES DE TEST - À ADAPTER SELON VOS BESOINS
// ============================================================================

System.debug('CONFIGURATION DES PARAMÈTRES DE TEST');
System.debug('=====================================');
System.debug('\n');

// Construction du body de la requête avec des valeurs de test
Map<String, Object> requestBody = new Map<String, Object>{
    'CITY_CODE' => '38000',           // ⚠️ Code postal/ville à adapter
    'ENERGY' => 'ELEC',                // Type d'énergie : ELEC ou GAS
    'PS' => '6',                       // Puissance souscrite
    'UIL_USAGE' => 'PRO',              // Usage : PRO, RES, etc.
    'GAS_TARIF_DIST' => '',            // Tarif distributeur gaz (si applicable)
    'GAS_NTR' => '',                   // NTR gaz (si applicable)
    'FREQ_TRANSMIS' => 'MONTHLY',      // Fréquence de transmission
    'GRID_USAGE' => 'C5',              // Usage réseau
    'OPT_TARIF' => 'BASE',             // Option tarifaire : BASE, HP/HC, etc.
    'CAR' => '5',                      // CAR
    'SERVICE_PACK' => 'STANDARD',      // Pack de services
    'REFDATE' => String.valueOf(System.today()), // Date de référence
    'DISTRIBUTOR' => 'ENEDIS',         // Distributeur
    'OPT_FTA' => '',                   // Option FTA
    'TARIF' => 'C5',                   // Tarif
    'GREEN_OPTION' => 'NO',            // Option verte : YES/NO
    'SERVICE_OPT' => new List<String>(), // Options de service
    'GREEN_RATE' => '0',               // Taux vert
    'DOM_TENSION' => 'BT'              // Domaine de tension : BT, HTA, etc.
};

System.debug('Paramètres de la requête:');
System.debug(JSON.serializePretty(requestBody));
System.debug('\n');

// ============================================================================
// APPEL DU SERVICE SAP PRODUCT CATALOG
// ============================================================================

System.debug('========================================');
System.debug('Appel du service Product Catalog...');
System.debug('========================================');
System.debug('\n');

try {
    // Création de la requête HTTP
    HttpRequest req = new HttpRequest();

    // Endpoint avec Named Credential
    String endpoint = 'callout:SAP_Product_Catalog_Service';
    req.setEndpoint(endpoint);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Accept', 'application/json');

    // Body JSON
    String jsonBody = JSON.serialize(requestBody);
    req.setBody(jsonBody);

    System.debug('Configuration de la requête:');
    System.debug('- Endpoint: ' + endpoint);
    System.debug('- Method: POST');
    System.debug('- Content-Type: application/json');
    System.debug('\n');

    // Envoi de la requête
    Http http = new Http();
    HttpResponse res = http.send(req);

    // ============================================================================
    // ANALYSE DE LA RÉPONSE
    // ============================================================================

    System.debug('\n');
    System.debug('=== RÉSULTAT DU TEST ===');
    System.debug('\n');

    Integer statusCode = res.getStatusCode();
    String status = res.getStatus();
    String responseBody = res.getBody();

    System.debug('Status Code: ' + statusCode);
    System.debug('Status: ' + status);
    System.debug('\n');

    // Vérification du résultat
    if (statusCode >= 200 && statusCode < 300) {
        System.debug('✓ SUCCÈS - Named Credential SAP_Product_Catalog_Service configuré correctement');
        System.debug('\n');

        // Analyse de la réponse JSON
        if (String.isNotBlank(responseBody)) {
            System.debug('--- RÉPONSE DU SERVICE ---');

            try {
                // Parser la réponse JSON
                List<Object> products = (List<Object>) JSON.deserializeUntyped(responseBody);

                System.debug('Nombre de produits retournés: ' + products.size());
                System.debug('\n');

                // Afficher chaque produit
                Integer counter = 1;
                for (Object productObj : products) {
                    Map<String, Object> product = (Map<String, Object>) productObj;

                    System.debug('─────────────────────────────────────────');
                    System.debug('PRODUIT #' + counter);
                    System.debug('─────────────────────────────────────────');

                    if (product.containsKey('PRODUCT')) {
                        System.debug('Code Produit: ' + product.get('PRODUCT'));
                    }

                    if (product.containsKey('DESCRIPTION')) {
                        System.debug('Description: ' + product.get('DESCRIPTION'));
                    }

                    // Afficher la simulation de prix
                    if (product.containsKey('SIMULATION')) {
                        Map<String, Object> simulation = (Map<String, Object>) product.get('SIMULATION');

                        System.debug('\nSIMULATION DE PRIX:');

                        if (simulation.containsKey('CURRENCY')) {
                            System.debug('Devise: ' + simulation.get('CURRENCY'));
                        }

                        if (simulation.containsKey('TOTAL_HT')) {
                            System.debug('Total HT: ' + simulation.get('TOTAL_HT'));
                        }

                        if (simulation.containsKey('TOTAL_TTC')) {
                            System.debug('Total TTC: ' + simulation.get('TOTAL_TTC'));
                        }

                        if (simulation.containsKey('MONTHLY_PAYMENT')) {
                            System.debug('Mensualité: ' + simulation.get('MONTHLY_PAYMENT'));
                        }

                        // Afficher les composants de prix
                        if (simulation.containsKey('PRICES')) {
                            List<Object> prices = (List<Object>) simulation.get('PRICES');
                            if (!prices.isEmpty()) {
                                System.debug('\nComposants de prix: ' + prices.size() + ' élément(s)');
                            }
                        }

                        // Afficher la configuration
                        if (simulation.containsKey('CONFIGURATION')) {
                            Map<String, Object> config = (Map<String, Object>) simulation.get('CONFIGURATION');
                            System.debug('\nConfiguration:');
                            if (config.containsKey('CODE_CONCESSION')) {
                                System.debug('- Code Concession: ' + config.get('CODE_CONCESSION'));
                            }
                            if (config.containsKey('ZONE_TARIF')) {
                                System.debug('- Zone Tarif: ' + config.get('ZONE_TARIF'));
                            }
                        }
                    }

                    System.debug('');
                    counter++;
                }

                // Afficher la réponse complète (limitée)
                System.debug('\n--- RÉPONSE JSON COMPLÈTE ---');
                if (responseBody.length() > 3000) {
                    System.debug(responseBody.substring(0, 3000) + '\n... (tronqué)');
                } else {
                    System.debug(responseBody);
                }

            } catch (JSONException e) {
                System.debug('⚠ AVERTISSEMENT: Impossible de parser la réponse JSON');
                System.debug('Erreur: ' + e.getMessage());
                System.debug('\nRéponse brute:');
                System.debug(responseBody);
            }

        } else {
            System.debug('⚠ AVERTISSEMENT: Réponse vide du service');
        }

    } else if (statusCode == 400) {
        System.debug('✗ ÉCHEC - Requête invalide (Bad Request)');
        System.debug('\n→ SOLUTIONS POSSIBLES:');
        System.debug('  - Vérifier les paramètres de la requête');
        System.debug('  - Un ou plusieurs champs sont invalides ou manquants');
        System.debug('  - Vérifier que les valeurs correspondent au format attendu par SAP');
        System.debug('\nRéponse du serveur:');
        System.debug(responseBody);

    } else if (statusCode == 401 || statusCode == 403) {
        System.debug('✗ ÉCHEC - Erreur d\'authentification');
        System.debug('\n→ SOLUTIONS POSSIBLES:');
        System.debug('  - Vérifier l\'External Credential: ProductCatalogExternalService');
        System.debug('  - Vérifier que les credentials SAP sont valides et non expirés');
        System.debug('  - Vérifier les permissions de l\'utilisateur SAP');
        System.debug('\nRéponse du serveur:');
        System.debug(responseBody);

    } else if (statusCode == 404) {
        System.debug('✗ ÉCHEC - Endpoint non trouvé');
        System.debug('\n→ SOLUTIONS POSSIBLES:');
        System.debug('  - Vérifier l\'URL dans le Named Credential SAP_Product_Catalog_Service');
        System.debug('  - URL attendue: https://geg-api.test.apimanagement.eu10.hana.ondemand.com:443/DF/ProductCatalog');
        System.debug('  - Vérifier que le service est déployé et accessible');
        System.debug('\nRéponse du serveur:');
        System.debug(responseBody);

    } else if (statusCode >= 500) {
        System.debug('✗ ÉCHEC - Erreur serveur SAP (5xx)');
        System.debug('\n→ SOLUTIONS POSSIBLES:');
        System.debug('  - Le service SAP rencontre une erreur interne');
        System.debug('  - Contacter l\'équipe SAP pour vérifier l\'état du service');
        System.debug('  - Vérifier les logs côté SAP');
        System.debug('\nRéponse du serveur:');
        System.debug(responseBody);

    } else {
        System.debug('⚠ AVERTISSEMENT - Code de statut inattendu: ' + statusCode);
        System.debug('\nRéponse du serveur:');
        System.debug(responseBody);
    }

} catch (System.CalloutException e) {
    System.debug('✗ ERREUR DE CALLOUT');
    System.debug('Message: ' + e.getMessage());
    System.debug('\n→ SOLUTIONS POSSIBLES:');

    if (e.getMessage().contains('Unauthorized endpoint')) {
        System.debug('  - L\'endpoint n\'est pas autorisé dans Remote Site Settings');
        System.debug('  - Allez dans Setup > Remote Site Settings');
        System.debug('  - Vérifiez que l\'URL SAP est autorisée');
        System.debug('  - URL: https://geg-api.test.apimanagement.eu10.hana.ondemand.com');
    } else if (e.getMessage().contains('Invalid named credential')) {
        System.debug('  - Vérifier que le Named Credential "SAP_Product_Catalog_Service" existe');
        System.debug('  - Vérifier qu\'il est actif et correctement configuré');
        System.debug('  - Vérifier l\'External Credential associé: ProductCatalogExternalService');
    } else if (e.getMessage().contains('timeout')) {
        System.debug('  - Le service SAP met trop de temps à répondre');
        System.debug('  - Vérifier la connectivité réseau vers SAP');
        System.debug('  - Le service pourrait être surchargé ou indisponible');
    } else {
        System.debug('  - Vérifier la configuration complète du Named Credential');
        System.debug('  - Vérifier l\'External Credential: ProductCatalogExternalService');
        System.debug('  - Vérifier que le service SAP est opérationnel');
    }

} catch (Exception e) {
    System.debug('✗ ERREUR INATTENDUE');
    System.debug('Type: ' + e.getTypeName());
    System.debug('Message: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

System.debug('\n');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('║     TEST SAP PRODUCT CATALOG SERVICE - FIN                     ║');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('\n');

// ============================================================================
// INFORMATIONS COMPLÉMENTAIRES
// ============================================================================

System.debug('NOTES:');
System.debug('- Ce script teste le Named Credential: SAP_Product_Catalog_Service');
System.debug('- Action: ProductCatalogInvocable (POST)');
System.debug('- Adaptez les paramètres de test selon vos besoins (CITY_CODE, ENERGY, etc.)');
System.debug('- Le service retourne une liste de produits avec simulations de prix');
System.debug('- Pour des logs détaillés: Debug > Change Log Levels > Apex Code = FINEST');
