/**
 * Script Apex Anonymous pour tester SAP_Endpoint_Service
 *
 * Ce script teste le Named Credential SAP_Endpoint_Service
 * en utilisant la classe SAPDetailPointServiceCallout
 *
 * IMPORTANT: Adaptez les valeurs de test (pointId, loginUtilisateur) selon vos besoins
 *
 * Exécution :
 * - Via Developer Console : Debug > Open Execute Anonymous Window
 * - Via SF CLI : sf apex run -f scripts/apex/testSAPEndpointService.apex -o origame5-dev
 */

System.debug('\n');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('║     TEST SAP ENDPOINT SERVICE - DÉBUT                          ║');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('\n');

// ============================================================================
// PARAMÈTRES DE TEST - À ADAPTER SELON VOS BESOINS
// ============================================================================

String pointId = '125278EC1';  // ⚠️ Remplacer par un point ID valide de test
String loginUtilisateur = 'khawla.trimeche@iliadeconsulting.com';  // ⚠️ Adapter si nécessaire
Boolean contratConcluNouveauClientSurSite = false;
Boolean autorisationClient = true;

System.debug('PARAMÈTRES DE TEST:');
System.debug('- Point ID: ' + pointId);
System.debug('- Login Utilisateur: ' + loginUtilisateur);
System.debug('- Contrat Conclu Nouveau Client: ' + contratConcluNouveauClientSurSite);
System.debug('- Autorisation Client: ' + autorisationClient);
System.debug('\n');

// ============================================================================
// CONFIGURATION DES DONNÉES DEMANDÉES
// ============================================================================

SAPDetailPointServiceCallout.DonneesDemandees donnees =
    new SAPDetailPointServiceCallout.DonneesDemandees();

// Configuration des données à récupérer
donnees.donneesGeneralesPoint = true;
donnees.derniersIndex = true;
donnees.modificationsContractuellesEnCours = false;
donnees.interventionsEnCours = false;
donnees.historiqueAffaires = false;
donnees.elementsProchainesMesures = false;

System.debug('DONNÉES DEMANDÉES:');
System.debug('- Données Générales Point: ' + donnees.donneesGeneralesPoint);
System.debug('- Derniers Index: ' + donnees.derniersIndex);
System.debug('- Modifications Contractuelles: ' + donnees.modificationsContractuellesEnCours);
System.debug('- Interventions En Cours: ' + donnees.interventionsEnCours);
System.debug('- Historique Affaires: ' + donnees.historiqueAffaires);
System.debug('- Éléments Prochaines Mesures: ' + donnees.elementsProchainesMesures);
System.debug('\n');

// ============================================================================
// APPEL DU SERVICE SAP
// ============================================================================

System.debug('========================================');
System.debug('Appel du service SAP Endpoint Service...');
System.debug('========================================');
System.debug('\n');

try {
    // Appel du service
    SAPDetailPointServiceCallout.SAPResponse response =
        SAPDetailPointServiceCallout.callSAP(
            pointId,
            loginUtilisateur,
            donnees,
            contratConcluNouveauClientSurSite,
            autorisationClient
        );

    System.debug('\n');
    System.debug('=== RÉSULTAT DU TEST ===');
    System.debug('\n');

    // Vérification du résultat
    if (response.isSuccess) {
        System.debug('✓ SUCCÈS - Named Credential SAP_Endpoint_Service configuré correctement');
        System.debug('Response Code: ' + response.responseCode);
        System.debug('Message: ' + response.defaultValue);
        System.debug('\n');

        // Analyse des données retournées
        if (response.data != null) {
            System.debug('--- DONNÉES REÇUES ---');
            Map<String, Object> data = (Map<String, Object>) response.data;

            // Afficher les clés principales
            System.debug('Clés disponibles dans la réponse: ' + data.keySet());

            // Si données de point disponibles
            if (data.containsKey('point')) {
                Map<String, Object> point = (Map<String, Object>) data.get('point');
                System.debug('\nDonnées du Point:');
                System.debug(JSON.serializePretty(point));
            }

            // Afficher toute la réponse (limitée)
            String fullResponse = JSON.serializePretty(data);
            if (fullResponse.length() > 2000) {
                System.debug('\nRéponse complète (preview - premiers 2000 caractères):');
                System.debug(fullResponse.substring(0, 2000) + '\n... (tronqué)');
            } else {
                System.debug('\nRéponse complète:');
                System.debug(fullResponse);
            }
        } else {
            System.debug('⚠️ AVERTISSEMENT: Réponse réussie mais aucune donnée retournée');
        }

    } else {
        System.debug('✗ ÉCHEC - Erreur lors de l\'appel');
        System.debug('Response Code: ' + response.responseCode);
        System.debug('Message d\'erreur: ' + response.defaultValue);
        System.debug('\n');

        // Suggestions selon le code d'erreur
        if (response.responseCode == '401' || response.responseCode == '403') {
            System.debug('→ SOLUTION SUGGÉRÉE:');
            System.debug('  - Vérifier l\'External Credential associé à SAP_Endpoint_Service');
            System.debug('  - Vérifier que les credentials SAP sont valides et non expirés');
            System.debug('  - Vérifier les permissions de l\'utilisateur SAP');
        } else if (response.responseCode == '404') {
            System.debug('→ SOLUTION SUGGÉRÉE:');
            System.debug('  - Vérifier que le point ID existe dans SAP: ' + pointId);
            System.debug('  - Vérifier l\'URL de l\'endpoint dans le Named Credential');
        } else if (response.responseCode == '500' || response.responseCode.startsWith('5')) {
            System.debug('→ SOLUTION SUGGÉRÉE:');
            System.debug('  - Erreur côté serveur SAP');
            System.debug('  - Vérifier les logs SAP ou contacter l\'équipe SAP');
            System.debug('  - Vérifier que le format de la requête est correct');
        } else {
            System.debug('→ SOLUTION SUGGÉRÉE:');
            System.debug('  - Consulter les logs détaillés ci-dessus');
            System.debug('  - Vérifier la configuration du Named Credential');
        }
    }

} catch (System.CalloutException e) {
    System.debug('✗ ERREUR DE CALLOUT');
    System.debug('Message: ' + e.getMessage());
    System.debug('Type: ' + e.getTypeName());
    System.debug('\n');
    System.debug('→ SOLUTIONS POSSIBLES:');

    if (e.getMessage().contains('Unauthorized endpoint')) {
        System.debug('  - Ajouter l\'endpoint SAP dans Remote Site Settings');
        System.debug('  - Setup > Remote Site Settings > New Remote Site');
    } else if (e.getMessage().contains('Invalid named credential')) {
        System.debug('  - Vérifier que le Named Credential "SAP_Endpoint_Service" existe');
        System.debug('  - Vérifier qu\'il est actif et correctement configuré');
    } else if (e.getMessage().contains('timeout')) {
        System.debug('  - Le service SAP met trop de temps à répondre');
        System.debug('  - Vérifier la connectivité réseau vers SAP');
        System.debug('  - Augmenter le timeout si nécessaire');
    } else {
        System.debug('  - Vérifier la configuration complète du Named Credential');
        System.debug('  - Vérifier l\'External Credential associé');
    }

} catch (Exception e) {
    System.debug('✗ ERREUR INATTENDUE');
    System.debug('Message: ' + e.getMessage());
    System.debug('Type: ' + e.getTypeName());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

System.debug('\n');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('║     TEST SAP ENDPOINT SERVICE - FIN                            ║');
System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('\n');

// ============================================================================
// INFORMATIONS COMPLÉMENTAIRES
// ============================================================================

System.debug('NOTES:');
System.debug('- Ce script teste le Named Credential: SAP_Endpoint_Service');
System.debug('- Endpoint: callout:SAP_Endpoint_Service/DetailPointService');
System.debug('- Méthode: POST avec body JSON structuré');
System.debug('- Pour des tests plus complets, modifiez les paramètres ci-dessus');
System.debug('- Pour activer les logs détaillés: Debug > Change Log Levels > Apex Code = FINEST');
