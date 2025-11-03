/**
 * Script Apex Anonymous pour tester les Named Credentials SAP
 *
 * Ce script teste les 3 Named Credentials configurés pour les callouts SAP :
 * 1. SAP BTP http
 * 2. SAP Endpoint Service
 * 3. SAP Product Catalog Service
 *
 * Exécution :
 * - Via Developer Console : Debug > Open Execute Anonymous Window
 * - Via SF CLI : sf apex run -f testNamedCredentials.apex -o origame5-dev
 */

public class NamedCredentialTester {

    /**
     * Teste un Named Credential spécifique
     */
    public static void testNamedCredential(String namedCredentialName, String relativeEndpoint, String httpMethod) {
        System.debug('========================================');
        System.debug('Test du Named Credential: ' + namedCredentialName);
        System.debug('========================================');

        try {
            // Construction de l'URL avec le Named Credential
            String endpoint = 'callout:' + namedCredentialName;
            if (String.isNotBlank(relativeEndpoint)) {
                endpoint += relativeEndpoint;
            }

            System.debug('Endpoint: ' + endpoint);
            System.debug('Méthode HTTP: ' + httpMethod);

            // Création de la requête HTTP
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod(httpMethod);
            req.setTimeout(120000); // Timeout de 120 secondes

            // En-têtes communs
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');

            // Si POST/PUT, ajouter un body vide
            if (httpMethod == 'POST' || httpMethod == 'PUT') {
                req.setBody('{}');
            }

            // Exécution du callout
            Http http = new Http();
            HttpResponse res = http.send(req);

            // Analyse de la réponse
            Integer statusCode = res.getStatusCode();
            String status = res.getStatus();
            String responseBody = res.getBody();

            System.debug('Status Code: ' + statusCode);
            System.debug('Status: ' + status);

            // Résultat du test
            if (statusCode >= 200 && statusCode < 300) {
                System.debug('✓ SUCCÈS - Named Credential configuré correctement');
            } else if (statusCode == 401 || statusCode == 403) {
                System.debug('✗ ÉCHEC - Erreur d\'authentification (vérifier External Credential)');
            } else if (statusCode == 404) {
                System.debug('⚠ AVERTISSEMENT - Endpoint non trouvé (vérifier l\'URL)');
            } else if (statusCode >= 500) {
                System.debug('✗ ÉCHEC - Erreur serveur SAP');
            } else {
                System.debug('⚠ AVERTISSEMENT - Status code inattendu: ' + statusCode);
            }

            // Afficher le début du corps de la réponse (limité pour les logs)
            if (String.isNotBlank(responseBody)) {
                String bodyPreview = responseBody.length() > 500 ?
                    responseBody.substring(0, 500) + '...' : responseBody;
                System.debug('Réponse (preview): ' + bodyPreview);
            }

        } catch (System.CalloutException e) {
            System.debug('✗ ÉCHEC - Erreur de callout: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());

            // Suggestions de résolution
            if (e.getMessage().contains('Unauthorized endpoint')) {
                System.debug('→ Solution: Vérifier les Remote Site Settings');
            } else if (e.getMessage().contains('Invalid named credential')) {
                System.debug('→ Solution: Vérifier que le Named Credential existe et est actif');
            }

        } catch (Exception e) {
            System.debug('✗ ÉCHEC - Erreur inattendue: ' + e.getMessage());
            System.debug('Type: ' + e.getTypeName());
            System.debug('Stack Trace: ' + e.getStackTraceString());
        }

        System.debug(''); // Ligne vide pour lisibilité
    }
}

// ============================================================================
// EXÉCUTION DES TESTS
// ============================================================================

System.debug('\n');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('║     TEST DES NAMED CREDENTIALS SAP - DÉBUT                     ║');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('\n');

// Test 1: SAP BTP http
// Endpoint: https://geg-distributeur-dev.it-cpi024-rt.cfapps.eu10-002.hana.ondemand.com/http/DF/SalesForce/activation
NamedCredentialTester.testNamedCredential(
    'SAP_BTP_http',  // Remplacer par le nom exact du Named Credential
    '',               // Le chemin complet est déjà dans le Named Credential
    'GET'             // Méthode HTTP (GET/POST selon votre API)
);

// Test 2: SAP Endpoint Service
// Endpoint: https://geg-api.test.apimanagement.eu10.hana.ondemand.com:443/DG
NamedCredentialTester.testNamedCredential(
    'SAP_Endpoint_Service',  // Remplacer par le nom exact du Named Credential
    '',                       // Le chemin complet est déjà dans le Named Credential
    'GET'                     // Méthode HTTP
);

// Test 3: SAP Product Catalog Service
// Endpoint: https://geg-api.test.apimanagement.eu10.hana.ondemand.com:443/DF/ProductCatalog
NamedCredentialTester.testNamedCredential(
    'SAP_Product_Catalog_Service',  // Remplacer par le nom exact du Named Credential
    '',                              // Le chemin complet est déjà dans le Named Credential
    'GET'                            // Méthode HTTP
);

System.debug('\n');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('║     TEST DES NAMED CREDENTIALS SAP - FIN                       ║');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('\n');

// ============================================================================
// INFORMATIONS COMPLÉMENTAIRES
// ============================================================================

System.debug('INFORMATIONS:');
System.debug('- Les Named Credentials utilisent les External Credentials pour l\'authentification');
System.debug('- Vérifier que les Named Credentials sont bien nommés (remplacer les underscores si nécessaire)');
System.debug('- Adapter les méthodes HTTP (GET/POST) selon vos besoins réels');
System.debug('- Pour plus de détails, activer le niveau de log "FINEST" pour System.debug');
