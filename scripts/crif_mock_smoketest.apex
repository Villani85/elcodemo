// CRIF Mock - Smoke Test
// Test P.IVA: IT01234567890

System.debug('=== CRIF MOCK SMOKE TEST ===');

String piva = 'IT01234567890';
System.debug('P.IVA test: ' + piva);

try {
    CrifMockClient.CrifMockResult r = CrifMockClient.searchByVat(
        piva,
        true,    // includeDataPacketList
        null,    // use default datapacket CSV
        0,       // page
        15,      // size
        'it-IT'  // acceptLanguage
    );

    System.debug('--- TOKEN ---');
    System.debug('TOKEN HTTP STATUS: ' + r.tokenHttpStatus);
    System.debug('TOKEN RAW: ' + r.tokenRaw);

    System.debug('--- SEARCH ---');
    System.debug('SEARCH HTTP STATUS: ' + r.searchHttpStatus);
    System.debug('SEARCH RAW: ' + r.searchRaw);

    if (r.error != null) {
        System.debug('*** ERRORE: ' + r.error);
    } else {
        System.debug('*** TEST COMPLETATO CON SUCCESSO ***');
    }

} catch (Exception e) {
    System.debug('*** ECCEZIONE: ' + e.getMessage());
    System.debug(e.getStackTraceString());
}
