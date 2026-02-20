@IsTest
public class RequiredFlsSecurityTest {

    // Test data setup
    @TestSetup
    static void setup() {
        // Create test User with Standard User profile (setup object - must be first)
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        User testUser = new User(
            Username = 'elco.operator.test.' + DateTime.now().getTime() + '@example.com',
            LastName = 'OperatorTest',
            Email = 'elco.operator.test@example.com',
            Alias = 'elcoop',
            TimeZoneSidKey = 'Europe/Rome',
            LocaleSidKey = 'it_IT',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'it',
            ProfileId = stdProfile.Id
        );
        insert testUser;

        // Assign permission sets (setup objects)
        PermissionSet visitOp = [SELECT Id FROM PermissionSet WHERE Name='Visit_Operator' LIMIT 1];
        PermissionSet techOp = [SELECT Id FROM PermissionSet WHERE Name='TechSpec_Operator' LIMIT 1];
        PermissionSet runFlows = [SELECT Id FROM PermissionSet WHERE Name='Elco_Run_Flows' LIMIT 1];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = visitOp.Id),
            new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = techOp.Id),
            new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = runFlows.Id)
        };

        // Use System.runAs to separate setup objects from non-setup objects
        System.runAs(testUser) {
            // Create test Account (non-setup object)
            Account acc = new Account(Name = 'ACCT FLS TEST');
            insert acc;

            // Create test Contact (non-setup object)
            Contact cont = new Contact(
                LastName = 'ContattoTest',
                AccountId = acc.Id,
                Email = 'test@example.com'
            );
            insert cont;
        }
    }

    @IsTest
    static void testVisitReportRequiredFields() {
        User testUser = [SELECT Id, Username, Profile.Name FROM User WHERE Email='elco.operator.test@example.com' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name='ACCT FLS TEST' LIMIT 1];

        Map<String, Object> result = new Map<String, Object>();
        result.put('objectName', 'Visit_Report__c');
        result.put('testUser', testUser.Username);

        System.runAs(testUser) {
            try {
                Visit_Report__c vr = new Visit_Report__c(
                    Account__c = acc.Id,
                    Subject__c = 'FLS Security Test',
                    Visit_DateTime__c = DateTime.now(),
                    Visit_Type__c = 'Visita'
                );

                List<Visit_Report__c> vrList = new List<Visit_Report__c>{vr};
                SObjectAccessDecision securityDecision = Security.stripInaccessible(
                    AccessType.CREATABLE,
                    vrList
                );

                Set<String> removedFields = securityDecision.getRemovedFields().get('Visit_Report__c');
                result.put('removedFields', removedFields != null ? new List<String>(removedFields) : new List<String>());

                List<Visit_Report__c> sanitizedRecords = securityDecision.getRecords();
                insert sanitizedRecords;

                result.put('insertSuccess', true);
                result.put('recordId', sanitizedRecords[0].Id);
                result.put('error', null);

            } catch (Exception e) {
                result.put('insertSuccess', false);
                result.put('error', e.getTypeName() + ': ' + e.getMessage());
            }
        }

        System.debug('VISIT_REPORT_RESULT:' + JSON.serializePretty(result));

        // Assert for test framework
        System.assertEquals(true, result.get('insertSuccess'),
            'Visit_Report__c insert should succeed. Error: ' + result.get('error'));
    }

    @IsTest
    static void testVisitAttendeeRequiredFields() {
        User testUser = [SELECT Id, Username FROM User WHERE Email='elco.operator.test@example.com' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name='ACCT FLS TEST' LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE Email='test@example.com' LIMIT 1];

        // Create Visit_Report as admin
        Visit_Report__c vr = new Visit_Report__c(
            Account__c = acc.Id,
            Subject__c = 'Visit for Attendee Test',
            Visit_DateTime__c = DateTime.now(),
            Visit_Type__c = 'Visita'
        );
        insert vr;

        Map<String, Object> result = new Map<String, Object>();
        result.put('objectName', 'Visit_Attendee__c');
        result.put('testUser', testUser.Username);

        System.runAs(testUser) {
            try {
                Visit_Attendee__c va = new Visit_Attendee__c(
                    Visit_Report__c = vr.Id,
                    Contact__c = cont.Id
                );

                List<Visit_Attendee__c> vaList = new List<Visit_Attendee__c>{va};
                SObjectAccessDecision securityDecision = Security.stripInaccessible(
                    AccessType.CREATABLE,
                    vaList
                );

                Set<String> removedFields = securityDecision.getRemovedFields().get('Visit_Attendee__c');
                result.put('removedFields', removedFields != null ? new List<String>(removedFields) : new List<String>());

                List<Visit_Attendee__c> sanitizedRecords = securityDecision.getRecords();
                insert sanitizedRecords;

                result.put('insertSuccess', true);
                result.put('recordId', sanitizedRecords[0].Id);
                result.put('error', null);

            } catch (Exception e) {
                result.put('insertSuccess', false);
                result.put('error', e.getTypeName() + ': ' + e.getMessage());
            }
        }

        System.debug('VISIT_ATTENDEE_RESULT:' + JSON.serializePretty(result));

        System.assertEquals(true, result.get('insertSuccess'),
            'Visit_Attendee__c insert should succeed. Error: ' + result.get('error'));
    }

    @IsTest
    static void testAccountTechSpecRequiredFields() {
        User testUser = [SELECT Id, Username FROM User WHERE Email='elco.operator.test@example.com' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name='ACCT FLS TEST' LIMIT 1];

        Map<String, Object> result = new Map<String, Object>();
        result.put('objectName', 'Account_Tech_Spec__c');
        result.put('testUser', testUser.Username);

        System.runAs(testUser) {
            try {
                Account_Tech_Spec__c ats = new Account_Tech_Spec__c(
                    Account__c = acc.Id,
                    Category__c = 'Materiali',
                    Parameter__c = 'Materiale principale',
                    Value__c = 'FR-4 TG150'
                );

                List<Account_Tech_Spec__c> atsList = new List<Account_Tech_Spec__c>{ats};
                SObjectAccessDecision securityDecision = Security.stripInaccessible(
                    AccessType.CREATABLE,
                    atsList
                );

                Set<String> removedFields = securityDecision.getRemovedFields().get('Account_Tech_Spec__c');
                result.put('removedFields', removedFields != null ? new List<String>(removedFields) : new List<String>());

                List<Account_Tech_Spec__c> sanitizedRecords = securityDecision.getRecords();
                insert sanitizedRecords;

                result.put('insertSuccess', true);
                result.put('recordId', sanitizedRecords[0].Id);
                result.put('error', null);

            } catch (Exception e) {
                result.put('insertSuccess', false);
                result.put('error', e.getTypeName() + ': ' + e.getMessage());
            }
        }

        System.debug('ACCOUNT_TECH_SPEC_RESULT:' + JSON.serializePretty(result));

        System.assertEquals(true, result.get('insertSuccess'),
            'Account_Tech_Spec__c insert should succeed. Error: ' + result.get('error'));
    }
}
