/**
 * Script Apex Anonymous pour tester SAP BTP HTTP (Service Activation)
 *
 * Ce script teste la connexion au service SAP BTP en récupérant le CSRF token.
 * Utilise le Custom Metadata Type SAP_IntegrationSettings__mdt
 *
 * IMPORTANT:
 * - Le Custom Metadata Type SAP_IntegrationSettings__mdt doit exister
 * - Il doit contenir : Endpoint__c, Username__c, Password__c
 *
 * Exécution :
 * - Via Developer Console : Debug > Open Execute Anonymous Window
 * - Via SF CLI : sf apex run -f scripts/apex/testSAPBTPActivation.apex -o origame5-dev
 */

System.debug('\n');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('║     TEST SAP BTP HTTP (SERVICE ACTIVATION) - DÉBUT             ║');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('\n');

// ============================================================================
// ÉTAPE 1 : Récupération des paramètres depuis Custom Metadata
// ============================================================================

System.debug('========================================');
System.debug('Récupération des paramètres de connexion...');
System.debug('========================================');
System.debug('\n');

try {
    // Récupérer les settings depuis Custom Metadata Type
    List<SAP_IntegrationSettings__mdt> settingsList = [
        SELECT Endpoint__c, Username__c, Password__c, MasterLabel
        FROM SAP_IntegrationSettings__mdt
        LIMIT 1
    ];

    if (settingsList.isEmpty()) {
        System.debug('✗ ERREUR: Aucun enregistrement trouvé dans SAP_IntegrationSettings__mdt');
        System.debug('\n→ SOLUTION:');
        System.debug('  1. Allez dans Setup > Custom Metadata Types');
        System.debug('  2. Cliquez sur SAP_IntegrationSettings');
        System.debug('  3. Créez un nouvel enregistrement avec :');
        System.debug('     - Endpoint__c : L\'URL du service SAP BTP');
        System.debug('     - Username__c : Votre nom d\'utilisateur SAP');
        System.debug('     - Password__c : Votre mot de passe SAP');
        return;
    }

    SAP_IntegrationSettings__mdt settings = settingsList[0];

    // Vérifier que les champs nécessaires sont renseignés
    if (String.isBlank(settings.Endpoint__c)) {
        System.debug('✗ ERREUR: Le champ Endpoint__c est vide dans SAP_IntegrationSettings__mdt');
        return;
    }

    if (String.isBlank(settings.Username__c) || String.isBlank(settings.Password__c)) {
        System.debug('✗ ERREUR: Les champs Username__c ou Password__c sont vides');
        return;
    }

    System.debug('✓ Paramètres récupérés avec succès');
    System.debug('Configuration utilisée: ' + settings.MasterLabel);
    System.debug('Endpoint: ' + settings.Endpoint__c);
    System.debug('Username: ' + settings.Username__c);
    System.debug('Password: ' + (String.isNotBlank(settings.Password__c) ? '****** (masqué)' : '(vide)'));
    System.debug('\n');

    // ============================================================================
    // ÉTAPE 2 : Test de connexion - Récupération du CSRF Token
    // ============================================================================

    System.debug('========================================');
    System.debug('Test de connexion au service SAP BTP...');
    System.debug('========================================');
    System.debug('\n');

    // Création de la requête GET pour récupérer le CSRF token
    HttpRequest getTokenRequest = new HttpRequest();
    getTokenRequest.setEndpoint(settings.Endpoint__c);
    getTokenRequest.setMethod('GET');
    getTokenRequest.setHeader('Content-Type', 'application/json');
    getTokenRequest.setHeader('x-csrf-token', 'Fetch');

    // Authentification Basic
    Blob headerValue = Blob.valueOf(settings.Username__c + ':' + settings.Password__c);
    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
    getTokenRequest.setHeader('Authorization', authorizationHeader);

    System.debug('Requête GET configurée:');
    System.debug('- Endpoint: ' + settings.Endpoint__c);
    System.debug('- Method: GET');
    System.debug('- Headers: Content-Type, x-csrf-token, Authorization');
    System.debug('\n');

    // Envoi de la requête
    Http http = new Http();
    HttpResponse getTokenResponse = http.send(getTokenRequest);

    // ============================================================================
    // ÉTAPE 3 : Analyse de la réponse
    // ============================================================================

    System.debug('=== RÉPONSE DU SERVICE SAP ===');
    System.debug('\n');

    Integer statusCode = getTokenResponse.getStatusCode();
    String status = getTokenResponse.getStatus();
    String csrfToken = getTokenResponse.getHeader('x-csrf-token');

    System.debug('Status Code: ' + statusCode);
    System.debug('Status: ' + status);
    System.debug('\n');

    // Vérification du résultat
    if (statusCode >= 200 && statusCode < 300) {
        System.debug('✓ SUCCÈS - Connexion au service SAP BTP établie');
        System.debug('\n');

        // Vérifier la présence du CSRF token
        if (String.isNotBlank(csrfToken)) {
            System.debug('✓ CSRF Token récupéré avec succès');
            System.debug('CSRF Token: ' + csrfToken);
        } else {
            System.debug('⚠ AVERTISSEMENT: Pas de CSRF Token dans la réponse');
            System.debug('  (Peut être normal selon la configuration du service)');
        }
        System.debug('\n');

        // Afficher tous les headers de réponse
        System.debug('--- HEADERS DE RÉPONSE ---');
        for (String headerKey : getTokenResponse.getHeaderKeys()) {
            System.debug(headerKey + ': ' + getTokenResponse.getHeader(headerKey));
        }
        System.debug('\n');

        // Afficher le body de la réponse (s'il y en a un)
        String responseBody = getTokenResponse.getBody();
        if (String.isNotBlank(responseBody)) {
            System.debug('--- BODY DE RÉPONSE ---');
            if (responseBody.length() > 1000) {
                System.debug(responseBody.substring(0, 1000) + '\n... (tronqué)');
            } else {
                System.debug(responseBody);
            }
        }

        // Vérifier la présence de cookies
        System.debug('\n--- COOKIES ---');
        Boolean hasCookies = false;
        for (String headerKey : getTokenResponse.getHeaderKeys()) {
            if (headerKey == 'Set-Cookie') {
                hasCookies = true;
                System.debug('Cookie: ' + getTokenResponse.getHeader(headerKey));
            }
        }
        if (!hasCookies) {
            System.debug('Aucun cookie retourné');
        }

    } else if (statusCode == 401 || statusCode == 403) {
        System.debug('✗ ÉCHEC - Erreur d\'authentification');
        System.debug('\n→ SOLUTIONS POSSIBLES:');
        System.debug('  - Vérifier le Username__c dans SAP_IntegrationSettings__mdt');
        System.debug('  - Vérifier le Password__c dans SAP_IntegrationSettings__mdt');
        System.debug('  - Vérifier que les credentials SAP sont valides et non expirés');
        System.debug('  - Vérifier les permissions de l\'utilisateur SAP');
        System.debug('\nBody de la réponse:');
        System.debug(getTokenResponse.getBody());

    } else if (statusCode == 404) {
        System.debug('✗ ÉCHEC - Endpoint non trouvé');
        System.debug('\n→ SOLUTIONS POSSIBLES:');
        System.debug('  - Vérifier l\'URL dans Endpoint__c de SAP_IntegrationSettings__mdt');
        System.debug('  - URL actuelle: ' + settings.Endpoint__c);
        System.debug('  - Vérifier que l\'URL est correcte et accessible');
        System.debug('\nBody de la réponse:');
        System.debug(getTokenResponse.getBody());

    } else if (statusCode >= 500) {
        System.debug('✗ ÉCHEC - Erreur serveur SAP (5xx)');
        System.debug('\n→ SOLUTIONS POSSIBLES:');
        System.debug('  - Le service SAP rencontre une erreur interne');
        System.debug('  - Contacter l\'équipe SAP pour vérifier l\'état du service');
        System.debug('  - Vérifier les logs côté SAP');
        System.debug('\nBody de la réponse:');
        System.debug(getTokenResponse.getBody());

    } else {
        System.debug('⚠ AVERTISSEMENT - Code de statut inattendu: ' + statusCode);
        System.debug('\nBody de la réponse:');
        System.debug(getTokenResponse.getBody());
    }

} catch (System.QueryException e) {
    System.debug('✗ ERREUR DE REQUÊTE SOQL');
    System.debug('Message: ' + e.getMessage());
    System.debug('\n→ SOLUTION:');
    System.debug('  Le Custom Metadata Type SAP_IntegrationSettings__mdt n\'existe pas ou');
    System.debug('  les champs Endpoint__c, Username__c, Password__c n\'existent pas.');
    System.debug('\n  Créez le Custom Metadata Type avec ces champs.');

} catch (System.CalloutException e) {
    System.debug('✗ ERREUR DE CALLOUT');
    System.debug('Message: ' + e.getMessage());
    System.debug('\n→ SOLUTIONS POSSIBLES:');

    if (e.getMessage().contains('Unauthorized endpoint')) {
        System.debug('  - L\'endpoint n\'est pas autorisé dans Remote Site Settings');
        System.debug('  - Allez dans Setup > Remote Site Settings');
        System.debug('  - Cliquez sur "New Remote Site"');
        System.debug('  - Ajoutez l\'URL de base du service SAP BTP');
    } else if (e.getMessage().contains('timeout')) {
        System.debug('  - Le service SAP met trop de temps à répondre');
        System.debug('  - Vérifier la connectivité réseau vers SAP');
        System.debug('  - Le service SAP est peut-être indisponible');
    } else {
        System.debug('  - Vérifier la configuration réseau');
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
System.debug('║     TEST SAP BTP HTTP (SERVICE ACTIVATION) - FIN               ║');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('\n');

// ============================================================================
// INFORMATIONS COMPLÉMENTAIRES
// ============================================================================

System.debug('NOTES:');
System.debug('- Ce script teste uniquement la connexion (GET pour CSRF token)');
System.debug('- Si le test réussit, le Named Credential et les credentials sont OK');
System.debug('- Le Custom Metadata Type SAP_IntegrationSettings__mdt doit être configuré');
System.debug('- Pour des logs détaillés: Debug > Change Log Levels > Apex Code = FINEST');
