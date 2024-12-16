@isTest
public class AccountTriggerHandlerTest {
    @isTest 
    static void testCreateAccountContactRelations() {
        Account acc1 = new Account(Name = 'Account 1', MissionStatus__c = 'active');
        Account acc2 = new Account(Name = 'Account 2', MissionStatus__c = 'active');
        insert new List<Account>{acc1, acc2};
            
       	Contact con1 = new Contact(LastName = 'Contact 1', AccountId = acc1.Id, isActive__c = true);
        Contact con2 = new Contact(LastName = 'Contact 2', AccountId = acc2.Id, isActive__c = true);
        Contact con3 = new Contact(LastName = 'Contact 3', AccountId = acc1.Id, isActive__c = true);
        insert new List<Contact>{con1, con2, con3};
            
            // Generate AccountContactRelation records
        List<AccountContactRelation> relations = new List<AccountContactRelation>();
        relations.add(new AccountContactRelation(AccountId = acc1.Id, ContactId = con2.Id));
        relations.add(new AccountContactRelation(AccountId = acc2.Id, ContactId = con1.Id));
        relations.add(new AccountContactRelation(AccountId = acc2.Id, ContactId = con3.Id));
        insert relations;
        Account accT = [Select Id FROM Account WHERE Name = 'Account 1'];
        accT.MissionStatus__c = 'canceled';
        update accT;
		Account accTAfterUpdate = [Select Id, MissionCanceledDate__c FROM Account WHERE Name = 'Account 1'];
        System.assertEquals(Date.today(), accTAfterUpdate.MissionCanceledDate__c , 'Expected same date');
        Contact cnt1 = [Select Id, isActive__c FROM Contact WHERE Name = 'Contact 1'];
        System.assertEquals(true, cnt1.IsActive__c , 'Expected true');
        Account accT2 = [Select Id FROM Account WHERE Name = 'Account 2'];
        accT2.MissionStatus__c = 'canceled';
        update accT2;
        Contact cnt2 = [Select Id, isActive__c FROM Contact WHERE Name = 'Contact 2'];
        System.assertEquals(false, cnt2.IsActive__c , 'Expected false');
        
    }
}