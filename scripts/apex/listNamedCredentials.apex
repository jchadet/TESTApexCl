/**
 * Script pour lister tous les Named Credentials de votre org
 *
 * Exécutez ce script AVANT le test pour obtenir les noms exacts
 * de vos Named Credentials à utiliser dans les callouts.
 */

System.debug('\n╔════════════════════════════════════════════════════════════════╗');
System.debug('║          LISTE DES NAMED CREDENTIALS DISPONIBLES              ║');
System.debug('╚════════════════════════════════════════════════════════════════╝\n');

// Requête SOQL pour obtenir tous les Named Credentials
List<NamedCredential> credentials = [
    SELECT DeveloperName, MasterLabel, Endpoint
    FROM NamedCredential
    ORDER BY MasterLabel
];

if (credentials.isEmpty()) {
    System.debug('⚠️ Aucun Named Credential trouvé dans cette org');
} else {
    System.debug('Nombre de Named Credentials trouvés: ' + credentials.size() + '\n');

    Integer counter = 1;
    for (NamedCredential nc : credentials) {
        System.debug('─────────────────────────────────────────────────────────────');
        System.debug(counter + '. ' + nc.MasterLabel);
        System.debug('   Developer Name: ' + nc.DeveloperName);
        System.debug('   Endpoint: ' + (nc.Endpoint != null ? nc.Endpoint : '(Non défini)'));
        System.debug('');
        counter++;
    }

    System.debug('─────────────────────────────────────────────────────────────\n');

    // Chercher spécifiquement les Named Credentials SAP
    System.debug('🔍 RECHERCHE DES NAMED CREDENTIALS SAP:\n');

    Boolean foundSAP = false;
    for (NamedCredential nc : credentials) {
        String name = nc.MasterLabel.toLowerCase();
        String devName = nc.DeveloperName.toLowerCase();

        if (name.contains('sap') || devName.contains('sap') ||
            (nc.Endpoint != null && nc.Endpoint.toLowerCase().contains('sap'))) {

            foundSAP = true;
            System.debug('✓ SAP Named Credential trouvé:');
            System.debug('  Nom à utiliser dans le callout: callout:' + nc.DeveloperName);
            System.debug('  Label: ' + nc.MasterLabel);
            System.debug('  Endpoint: ' + nc.Endpoint);
            System.debug('');
        }
    }

    if (!foundSAP) {
        System.debug('⚠️ Aucun Named Credential SAP trouvé par recherche automatique');
        System.debug('   Vérifiez manuellement dans la liste ci-dessus\n');
    }
}

System.debug('╔════════════════════════════════════════════════════════════════╗');
System.debug('║ INSTRUCTIONS POUR LE TEST                                      ║');
System.debug('╚════════════════════════════════════════════════════════════════╝');
System.debug('');
System.debug('1. Notez le "Developer Name" des Named Credentials que vous voulez tester');
System.debug('2. Ouvrez le fichier testNamedCredentials-simple.apex');
System.debug('3. Remplacez les noms dans les callouts par les "Developer Name" ci-dessus');
System.debug('4. Exécutez le script de test');
System.debug('');
